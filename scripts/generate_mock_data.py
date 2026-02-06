#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Gera dados de transação fictícios (mock) com base no contrato de dados definido.
Pode opcionalmente incluir registros inválidos para testar scripts de validação.
"""

import json
import uuid
from pathlib import Path
from typing import Any, Dict, List

import typer
from faker import Faker

# Inicializa o Faker, usando o provedor brasileiro para CPF
fake = Faker("pt_BR")

app = typer.Typer()


def generate_transaction(is_invalid: bool = False) -> Dict[str, Any]:
    """
    Gera um único registro de transação fictícia.

    Args:
        is_invalid: Se True, gera um registro que viola o contrato de dados.

    Returns:
        Um dicionário representando uma única transação.
    """
    if is_invalid:
        return {
            "transaction_id": str(uuid.uuid4()),
            "user_id": str(uuid.uuid4()),
            "user_email": "not-an-email",  # Formato de e-mail inválido
            "user_cpf": "12345",  # Padrão de CPF inválido
            "transaction_amount": -50.0,  # Valor inválido (deve ser positivo)
            "transaction_timestamp": fake.iso8601(),
            "payment_method": "cash",  # Valor de enumeração inválido
        }

    return {
        "transaction_id": str(uuid.uuid4()),
        "user_id": str(uuid.uuid4()),
        "user_email": fake.email(),
        "user_cpf": fake.cpf().replace(".", "").replace("-", ""),
        "transaction_amount": round(
            fake.random_number(digits=4, fix_len=False) / 100, 2
        ),
        "transaction_timestamp": fake.iso8601(),
        "payment_method": fake.random_element(
            elements=("credit_card", "debit_card", "pix", "boleto")
        ),
    }


@app.command()
def generate(
    num_records: int = typer.Option(
        100, "--num-records", "-n", help="Número de registros fictícios a serem gerados."
    ),
    num_invalid: int = typer.Option(
        0, "--num-invalid", "-i", help="Número de registros inválidos a serem injetados."
    ),
    output_file: Path = typer.Option(
        "mock_transactions.json",
        "--output-file",
        "-o",
        help="Caminho para o arquivo JSON de saída.",
        writable=True,
        resolve_path=True,
    ),
):
    """
    Cria um arquivo com dados de transação fictícios.
    """
    if num_invalid > num_records:
        typer.secho(
            "O número de registros inválidos não pode exceder o número total de registros.",
            fg=typer.colors.RED,
        )
        raise typer.Exit(code=1)

    typer.echo(f"Gerando {num_records} registros no total ({num_invalid} inválidos)...")

    mock_data: List[Dict[str, Any]] = []
    for i in range(num_records):
        mock_data.append(generate_transaction(is_invalid=(i < num_invalid)))

    try:
        with open(output_file, "w") as f:
            json.dump(mock_data, f, indent=2)
        typer.secho(
            f"Dados gerados com sucesso em {output_file}", fg=typer.colors.GREEN
        )
    except IOError as e:
        typer.secho(f"Erro ao escrever no arquivo {output_file}: {e}", fg=typer.colors.RED)
        raise typer.Exit(code=1)


if __name__ == "__main__":
    app()
