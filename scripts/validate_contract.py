#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Validates a data file against a specified data contract using Pydantic.
"""

import json
from pathlib import Path
from typing import Any, Dict, List, Tuple, Type

import typer
import yaml
from pydantic import BaseModel, create_model

app = typer.Typer()

# --- Pydantic Model Generation from YAML ---

# A mapping from YAML types to Python types
YAML_TO_PYTHON_TYPE_MAP = {
    "string": str,
    "number": float,
    "integer": int,
    "boolean": bool,
    "array": list,
    "object": dict,
}

def create_pydantic_model_from_contract(contract_path: Path) -> Type[BaseModel]:
    """
    Dynamically creates a Pydantic model from a YAML data contract.

    Args:
        contract_path: Path to the YAML data contract file.

    Returns:
        A Pydantic BaseModel class generated based on the contract's schema.
    """
    try:
        with open(contract_path, "r") as f:
            contract = yaml.safe_load(f)
    except (IOError, yaml.YAMLError) as e:
        typer.secho(f"Error loading or parsing contract file {contract_path}: {e}", fg=typer.colors.RED)
        raise typer.Exit(code=1)

    schema = contract.get("schema")
    if not schema:
        typer.secho("Contract is missing 'schema' definition.", fg=typer.colors.RED)
        raise typer.Exit(code=1)

    fields: Dict[str, Tuple[Any, ...]] = {}
    for field_name, properties in schema.items():
        field_type_str = properties.get("type")
        python_type = YAML_TO_PYTHON_TYPE_MAP.get(field_type_str)

        if python_type is None:
            typer.secho(f"Unsupported type '{field_type_str}' for field '{field_name}'.", fg=typer.colors.RED)
            raise typer.Exit(code=1)
        
        # For simplicity, we make all fields required if not specified otherwise
        # Pydantic v2 uses '...' for required fields
        if properties.get("required", False):
            fields[field_name] = (python_type, ...)
        else:
            fields[field_name] = (python_type, None)

    Model = create_model("ContractModel", **fields)
    return Model


# --- Data Validation Logic ---

@app.command()
def validate(
    data_file: Path = typer.Option(
        ..., "--data-file", "-d", help="Path to the JSON data file to validate.",
        exists=True, readable=True, resolve_path=True,
    ),
    contract_file: Path = typer.Option(
        "contracts/transactions_v1.yaml", "--contract", "-c", help="Path to the data contract YAML file.",
        exists=True, readable=True, resolve_path=True,
    ),
):
    """
    Validates data in a file against a data contract.
    """
    typer.echo(f"Loading contract from: {contract_file}")
    ContractModel = create_pydantic_model_from_contract(contract_file)
    typer.secho("Contract model created successfully.", fg=typer.colors.BLUE)

    typer.echo(f"Loading data from: {data_file}")
    try:
        with open(data_file, "r") as f:
            data = json.load(f)
    except (IOError, json.JSONDecodeError) as e:
        typer.secho(f"Error loading data file {data_file}: {e}", fg=typer.colors.RED)
        raise typer.Exit(code=1)
    
    if not isinstance(data, list):
        typer.secho(f"Data file must contain a JSON list of records.", fg=typer.colors.RED)
        raise typer.Exit(code=1)

    valid_records: List[Dict] = []
    invalid_records: List[Dict] = []
    
    typer.echo(f"Validating {len(data)} records...")
    
    for i, record in enumerate(data):
        try:
            ContractModel.model_validate(record)
            valid_records.append(record)
        except Exception as e:
            invalid_record_info = {"record_index": i, "record_data": record, "errors": str(e)}
            invalid_records.append(invalid_record_info)

    if not invalid_records:
        typer.secho(f"Validation successful! All {len(valid_records)} records are valid.", fg=typer.colors.GREEN)
    else:
        typer.secho(f"Validation finished. Valid: {len(valid_records)}, Invalid: {len(invalid_records)}.", fg=typer.colors.YELLOW)
        typer.echo("--- Invalid Records ---")
        for invalid in invalid_records:
            typer.echo(json.dumps(invalid, indent=2))
        
        # In a real pipeline, you would move the invalid file to a "rejected" area
        # e.g., gsutil mv {data_file} gs://{bucket}/rejected/{data_file.name}
        
        raise typer.Exit(code=1) # Exit with error code if validation fails

if __name__ == "__main__":
    app()
