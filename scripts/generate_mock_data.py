#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Generates mock transaction data based on the defined data contract.
"""

import json
import uuid
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any

import typer
from faker import Faker

# Initialize Faker, using the Brazilian provider for CPF
fake = Faker("pt_BR")

app = typer.Typer()

def generate_transaction() -> Dict[str, Any]:
    """
    Generates a single mock transaction record.

    Returns:
        A dictionary representing a single transaction.
    """
    return {
        "transaction_id": str(uuid.uuid4()),
        "user_id": str(uuid.uuid4()),
        "user_email": fake.email(),
        "user_cpf": fake.cpf().replace(".", "").replace("-", ""),
        "transaction_amount": round(fake.random_number(digits=4, fix_len=False) / 100, 2),
        "transaction_timestamp": fake.iso8601(),
        "payment_method": fake.random_element(elements=("credit_card", "debit_card", "pix", "boleto")),
    }

@app.command()
def generate(
    num_records: int = typer.Option(100, "--num-records", "-n", help="Number of mock records to generate."),
    output_file: Path = typer.Option(
        "mock_transactions.json",
        "--output-file",
        "-o",
        help="Path to the output JSON file.",
        writable=True,
        resolve_path=True,
    ),
):
    """
    Creates a file with mock transaction data.
    """
    typer.echo(f"Generating {num_records} mock transaction records...")

    mock_data: List[Dict[str, Any]] = [generate_transaction() for _ in range(num_records)]

    try:
        with open(output_file, "w") as f:
            json.dump(mock_data, f, indent=2)
        typer.secho(f"Successfully generated data in {output_file}", fg=typer.colors.GREEN)
    except IOError as e:
        typer.secho(f"Error writing to file {output_file}: {e}", fg=typer.colors.RED)
        raise typer.Exit(code=1)

if __name__ == "__main__":
    app()
