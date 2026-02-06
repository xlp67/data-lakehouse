# SecureGuard Lakehouse

Este projeto implementa uma infraestrutura de Lakehouse modular e segura no Google Cloud Platform (GCP) para ingerir, validar, anonimizar e analisar dados de transações financeiras.

O sistema foi construído seguindo as melhores práticas de Engenharia de Plataforma, com foco em modularidade (Terraform), validação por contratos de dados (Data Contracts) e um pipeline de CI/CD robusto.

## Arquitetura

O fluxo de dados segue o padrão de arquitetura Medalhão (Bronze, Silver, Gold):

1.  **Ingestão**: Arquivos de dados brutos (JSON) são enviados para um bucket do Google Cloud Storage (GCS), que atua como a camada **Bronze**.
2.  **Validação (Gatekeeper)**: Um script Python (`scripts/validate_contract.py`) é acionado para validar os dados recebidos contra um `Data Contract` definido. Arquivos inválidos seriam movidos para uma área de rejeição.
3.  **Transformação e Anonimização**: O DBT (Data Build Tool) orquestra a transformação dos dados.
    *   **Camada Silver**: Os dados brutos da camada Bronze são limpos, tipados e, crucialmente, as colunas com Informações de Identificação Pessoal (PII) como `user_email` e `user_cpf` são anonimizadas usando uma função de hash (SHA256 + SALT).
    *   **Camada Gold**: A partir da camada Silver, são criados modelos de dados agregados e prontos para o consumo por ferramentas de BI, Analytics e Machine Learning.
4.  **Armazenamento**: Todas as camadas (Bronze, Silver, Gold) são fisicamente representadas como datasets no BigQuery.

```
[Raw JSON Files] -> [GCS Bucket (Bronze)] -> [Python Validator] -> [BigQuery (Bronze)]
                                                                           |
                                                                           v
                                                                   [DBT Transformation]
                                                                           |
                                                                           v
                                                         [BigQuery (Silver, Gold)] -> [BI / Analytics]
```

## Stack Tecnológico

*   **IaC**: Terraform (Modularizado, com Remote Backend no GCS)
*   **Linguagem**: Python 3.10+ (Pydantic, Typer, Faker)
*   **Transformação**: DBT Core
*   **CI/CD**: GitHub Actions
*   **Cloud**: GCP (GCS, BigQuery, IAM)

---

## Como Executar o Projeto

### Pré-requisitos

1.  [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) instalado e autenticado.
2.  [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) instalado.
3.  [Python 3.10+](https://www.python.org/downloads/) instalado.
4.  Um projeto GCP com faturamento ativado.
5.  Um bucket GCS para armazenar o estado do Terraform (remote backend). **Atualize o nome no arquivo `terraform/backend.tf`**.

### 1. Configuração do Ambiente Python

É altamente recomendado usar um ambiente virtual.

```bash
# Navegue até a raiz do projeto
cd secure-guard-lakehouse

# Crie o ambiente virtual
python3 -m venv .venv

# Ative o ambiente
source .venv/bin/activate

# Instale as dependências
pip install -r requirements.txt
```

### 2. Implantação da Infraestrutura com Terraform

1.  Navegue até o diretório do Terraform:
    ```bash
    cd terraform
    ```
2.  Inicialize o Terraform. Ele fará o download dos providers necessários e configurará o backend.
    ```bash
    terraform init
    ```
3.  Planeje a implantação. Substitua `your-gcp-project-id` pelo ID do seu projeto no GCP.
    ```bash
    terraform plan -var="gcp_project_id=your-gcp-project-id"
    ```
4.  Se o plano estiver correto, aplique as mudanças para criar a infraestrutura.
    ```bash
    terraform apply -var="gcp_project_id=your-gcp-project-id"
    ```

### 3. Execução do Pipeline de Dados (Simulação Local)

1.  **Gere dados de teste**:
    ```bash
    python scripts/generate_mock_data.py --output-file mock_data.json
    ```
2.  **Valide os dados contra o contrato**:
    ```bash
    python scripts/validate_contract.py --data-file mock_data.json
    ```
3.  **Execute as transformações com DBT**:
    *   Configure seu perfil do DBT (`~/.dbt/profiles.yml`) para conectar ao seu projeto BigQuery.
    *   Execute os modelos do DBT:
    ```bash
    # Navegue até o diretório do dbt
    cd dbt_project

    # Execute todos os modelos e testes
    dbt build --vars '{"PII_SALT_SECRET": "some-strong-secret-for-local-dev"}'
    ```

---

## Architecture Decision Log (ADL)

### Por que o Terraform foi Modularizado?

A decisão de estruturar o código Terraform em módulos (`gcs`, `bigquery`, `iam`) em vez de um único arquivo `main.tf` foi deliberada e baseada nos seguintes princípios de engenharia de software e DevOps:

1.  **Reutilização (DRY - Don't Repeat Yourself)**: Módulos são, por natureza, reutilizáveis. Se precisássemos criar um segundo bucket com a mesma configuração (versionamento, lifecycle), poderíamos simplesmente instanciar o módulo `gcs` novamente com variáveis diferentes. Isso evita a duplicação de código, que é uma fonte comum de erros e inconsistências.

2.  **Isolamento e Manutenção Simplificada**: Cada módulo gerencia um conjunto lógico e coeso de recursos. Se uma alteração for necessária nos datasets do BigQuery, o desenvolvedor pode se concentrar exclusivamente no módulo `bigquery`, entendendo rapidamente seu escopo e impacto, sem precisar navegar por um arquivo gigante com recursos misturados.

3.  **Gerenciamento de Estado (State Management)**: Embora este projeto use um único arquivo de estado, em sistemas maiores, a modularização é o primeiro passo para o isolamento de estado. Poderíamos, por exemplo, gerenciar o estado da infraestrutura de rede em um workspace Terraform separado do estado da aplicação. Módulos facilitam essa separação, reduzindo o "raio de explosão" de um `terraform apply` e permitindo que equipes diferentes trabalhem em paralelo com mais segurança.

4.  **Clareza e Legibilidade**: O arquivo `main.tf` do root module se torna uma representação de alto nível da arquitetura da plataforma. Ele declara *o que* a infraestrutura contém (um bucket, datasets, uma service account), enquanto os detalhes de *como* esses recursos são configurados ficam encapsulados dentro dos módulos. Isso torna o código mais fácil de ler e entender para novos membros da equipe.

Em resumo, a modularização do Terraform eleva o código de infraestrutura de um simples "script" para uma "plataforma" coesa, manutenível e escalável, refletindo uma mentalidade de produto sobre o código de IaC.
# data-lakehouse
