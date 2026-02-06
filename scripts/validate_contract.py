#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Valida um arquivo de dados contra um contrato de dados específico usando Pydantic.
Esta versão inclui validação avançada para formatos, padrões e enums.
"""

import json
from enum import Enum
from pathlib import Path
from typing import Any, Dict, List, Type

import typer
import yaml
from pydantic import BaseModel, EmailStr, Field, create_model

app = typer.Typer()

# --- Geração de Modelo Pydantic a partir do YAML ---

# Mapeamento de tipos YAML para tipos Python/Pydantic
YAML_TO_PYDANTIC_TYPE_MAP = {
    "string": str,
    "number": float,
    "integer": int,
    "boolean": bool,
    "array": list,
    "object": dict,
}


def create_pydantic_model_from_contract(contract_path: Path) -> Type[BaseModel]:
    """
    Cria dinamicamente um modelo Pydantic a partir de um contrato de dados YAML,
    incluindo regras de validação avançadas como enums, padrões e formatos.

    Args:
        contract_path: Caminho para o arquivo do contrato de dados YAML.

    Returns:
        Uma classe Pydantic BaseModel gerada com base no esquema do contrato.
    """
    try:
        with open(contract_path, "r") as f:
            contract = yaml.safe_load(f)
    except (IOError, yaml.YAMLError) as e:
        typer.secho(
            f"Erro ao carregar ou analisar o arquivo de contrato {contract_path}: {e}",
            fg=typer.colors.RED,
        )
        raise typer.Exit(code=1)

    schema = contract.get("schema")
    if not schema:
        typer.secho("O contrato não possui a definição 'schema'.", fg=typer.colors.RED)
        raise typer.Exit(code=1)

    fields: Dict[str, Any] = {}
    for field_name, properties in schema.items():
        field_type_str = properties.get("type")
        python_type = YAML_TO_PYDANTIC_TYPE_MAP.get(field_type_str, Any)

        # --- Validação Avançada ---
        field_validators = []

        # Lida com enums
        if "enum" in properties:
            enum_name = f"{field_name.capitalize()}Enum"
            python_type = Enum(enum_name, {v: v for v in properties["enum"]})

        # Lida com formatos e padrões de string
        if python_type is str:
            if properties.get("format") == "email":
                python_type = EmailStr

            pattern = properties.get("pattern")
            if pattern:
                # Pydantic v2 usa Field para restrições
                field_validators.append(Field(pattern=pattern))

        # Determina se o campo é obrigatório
        default_value = ... if properties.get("required", False) else None

        if field_validators:
            fields[field_name] = (python_type, field_validators[0])
        else:
            fields[field_name] = (python_type, default_value)

    Model = create_model("ContractModel", **fields)
    return Model


# --- Lógica de Validação de Dados ---


@app.command()
def validate(
    data_file: Path = typer.Option(
        ...,
        "--data-file",
        "-d",
        help="Caminho para o arquivo de dados JSON a ser validado.",
        exists=True,
        readable=True,
        resolve_path=True,
    ),
    contract_file: Path = typer.Option(
        "contracts/transactions_v1.yaml",
        "--contract",
        "-c",
        help="Caminho para o arquivo YAML do contrato de dados.",
        exists=True,
        readable=True,
        resolve_path=True,
    ),
):
    """
    Valida dados em um arquivo contra um contrato de dados.
    """
    typer.echo(f"Carregando contrato de: {contract_file}")
    ContractModel = create_pydantic_model_from_contract(contract_file)
    typer.secho(
        "Modelo de contrato criado com sucesso com validação avançada.",
        fg=typer.colors.BLUE,
    )

    typer.echo(f"Carregando dados de: {data_file}")
    try:
        with open(data_file, "r") as f:
            data = json.load(f)
    except (IOError, json.JSONDecodeError) as e:
        typer.secho(f"Erro ao carregar o arquivo de dados {data_file}: {e}", fg=typer.colors.RED)
        raise typer.Exit(code=1)

    if not isinstance(data, list):
        typer.secho(
            "O arquivo de dados deve conter uma lista JSON de registros.", fg=typer.colors.RED
        )
        raise typer.Exit(code=1)

    valid_records: List[Dict] = []
    invalid_records: List[Dict] = []

    typer.echo(f"Validando {len(data)} registros com regras estritas...")

    for i, record in enumerate(data):
        try:
            # Pydantic v2 usa model_validate
            ContractModel.model_validate(record)
            valid_records.append(record)
        except Exception as e:
            invalid_record_info = {
                "record_index": i,
                "record_data": record,
                "errors": str(e),
            }
            invalid_records.append(invalid_record_info)

    if not invalid_records:
        typer.secho(
            f"Validação bem-sucedida! Todos os {len(valid_records)} registros são válidos.",
            fg=typer.colors.GREEN,
        )
    else:
        typer.secho(
            f"Validação concluída. Válidos: {len(valid_records)}, Inválidos: {len(invalid_records)}.",
            fg=typer.colors.YELLOW,
        )
        typer.echo("--- Registros Inválidos ---")
        for invalid in invalid_records:
            typer.echo(json.dumps(invalid, indent=2))

        raise typer.Exit(code=1)


if __name__ == "__main__":
    app()
