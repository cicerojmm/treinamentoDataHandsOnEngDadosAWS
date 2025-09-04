# Treinamento Engenharia de Dados

Projeto completo de engenharia de dados com pipeline de ingestão, processamento e análise usando tecnologias AWS e ferramentas open source.

## 🏗️ Arquitetura

### Componentes Principais:
- **PostgreSQL RDS** - Banco de dados transacional
- **DMS Serverless** - Replicação CDC para S3
- **Debezium + Kafka** - Streaming de mudanças em tempo real
- **AWS Glue** - ETL e processamento de dados
- **S3 Tables (Iceberg)** - Data Lake com formato Iceberg
- **Step Functions** - Orquestração de workflows
- **OpenSearch** - Busca e analytics em tempo real

## 📁 Estrutura do Projeto

```
TreinamentoEngenhariaDados/
├── terraform/infra/          # Infraestrutura como código
│   ├── modules/             # Módulos Terraform reutilizáveis
│   ├── scripts/             # Scripts Glue, Lambda e Step Functions
│   └── envs/               # Configurações por ambiente
├── debezium/               # Configuração Debezium + Kafka
├── opensearch/             # Stack OpenSearch
├── jars/                   # JARs para Spark e Debezium
└── scripts/                # Scripts utilitários
```

## 🚀 Módulos Terraform

### VPC (`modules/vpc`)
- VPC com subnets públicas e privadas
- Internet Gateway e Route Tables
- VPC Endpoints para S3
- DMS Replication Subnet Group

### RDS PostgreSQL (`modules/rds`)
- Instância PostgreSQL 17.5
- Security Groups configurados
- Parameter Groups customizados
- Configurado para CDC

### DMS Serverless (`modules/dms-serverless`)
- Source Endpoint (PostgreSQL)
- Target Endpoint (S3)
- Replication Task para CDC
- IAM Roles necessárias

### Glue Jobs (`modules/glue-job`)
- Jobs ETL para S3 Tables (Iceberg)
- Processamento de dimensões e fatos
- Data Quality com Great Expectations
- Suporte a JARs customizados

### Step Functions (`modules/step-functions`)
- Orquestração de workflows ETL
- Integração com Glue Jobs
- Logging e monitoramento

### Lambda ECR (`modules/lambda_ecr`)
- Funções Lambda com Docker
- Integração com DuckDB
- Function URLs configuradas

### EC2 (`modules/ec2`)
- Instâncias para processamento
- Security Groups configurados
- Bootstrap scripts

## 🔧 Deploy da Infraestrutura

### 1. Configurar Backend
```bash
cd terraform/infra
terraform init -backend-config="backends/develop.hcl"
```

### 2. Aplicar Terraform
```bash
terraform apply -var-file=envs/develop.tfvars -auto-approve
```

### 3. Iniciar Replicação DMS
```bash
./modules/dms-serverless/start_replication.sh dev
```

## 📊 Pipeline de Dados

### 1. Ingestão
- **DMS**: Replica dados do PostgreSQL para S3 (full-load + CDC)
- **Debezium**: Captura mudanças em tempo real via Kafka

### 2. Processamento
- **Glue ETL**: Transforma dados raw em dimensões e fatos
- **S3 Tables**: Armazena dados em formato Iceberg
- **Step Functions**: Orquestra pipeline ETL

### 3. Consumo
- **OpenSearch**: Analytics e busca em tempo real
- **Lambda + DuckDB**: Queries analíticas
- **S3 Tables**: Consultas SQL diretas

## 🔄 Configuração CDC

### RDS PostgreSQL
```sql
-- Configurações necessárias no Parameter Group
rds.logical_replication = 1
max_replication_slots = 10
max_wal_senders = 10
```

### Debezium + Kafka
```bash
cd debezium
docker-compose up -d
```

## 🧪 S3 Tables Iceberg

### Configurar Connector
1. Build do connector oficial:
```bash
./debezium/build-iceberg-s3-connect.sh
```

2. Copiar JARs:
```bash
# Connector Iceberg
/iceberg/kafka-connect/kafka-connect-runtime/build/distributions/iceberg-kafka-connect-runtime-1.10.0-SNAPSHOT.zip

# JARs Debezium
cp jars/debezium/* debezium/
```

## 🔍 OpenSearch

### Deploy
```bash
cd opensearch
docker-compose up -d
```

### Acesso
- **URL**: http://localhost:5601
- **Usuário**: admin
- **Senha**: admin

## 📝 Scripts Disponíveis

### Glue ETL
- `datahandson-engdados-amazonsales-dw-table-stg-s3tables.py` - Staging
- `datahandson-engdados-amazonsales-dw-dim-*.py` - Dimensões
- `datahandson-engdados-amazonsales-dw-fact-*.py` - Fatos
- `*-gdq.py` - Data Quality

### Spark Streaming
- `datahandson-engdados-webevents-streaming-kafka-opensearch.py`

### Lambda
- `lambda_handler.py` - Queries com DuckDB

### Utilitários
- `script-insert-postgres-webfake-events.py` - Geração de dados fake

## 🛠️ Monitoramento

### DMS
```bash
./modules/dms-serverless/monitor_replication.sh dev
```

### Step Functions
- Console AWS Step Functions
- CloudWatch Logs

### Glue Jobs
- Console AWS Glue
- CloudWatch Metrics

## 📋 Variáveis de Ambiente

### Desenvolvimento (`envs/develop.tfvars`)
```hcl
environment = "dev"
region = "us-east-2"
s3_bucket_raw = "cjmm-mds-lake-raw"
s3_bucket_scripts = "cjmm-mds-lake-configs"
s3_bucket_curated = "cjmm-mds-lake-curated"
```

## 🔐 Segurança

- IAM Roles com princípio de menor privilégio
- Security Groups restritivos
- VPC Endpoints para comunicação privada
- Criptografia em trânsito e repouso

## 🔄 CI/CD com GitHub Actions

### Pipeline Terraform (`github-actions/terraform.yml`)
- **Triggers**: Pull requests e pushes para `develop` e `main`
- **Ambientes**: Automático baseado na branch
  - `develop` → ambiente `dev`
  - `main` → ambiente `prod`
- **Steps**:
  - Terraform fmt, validate e plan
  - Apply automático em push para branches principais
  - Upload de artifacts do plan em PRs

### Configuração
```yaml
# Secrets necessários no GitHub:
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### Uso
1. **Pull Request**: Executa plan e valida código
2. **Merge**: Aplica mudanças automaticamente
3. **Artifacts**: Plan disponível para review

## 📚 Tecnologias

- **AWS**: RDS, DMS, Glue, Step Functions, Lambda, S3
- **Terraform**: Infraestrutura como código
- **GitHub Actions**: CI/CD pipeline
- **Apache Kafka**: Streaming de dados
- **Debezium**: Change Data Capture
- **Apache Iceberg**: Table format para Data Lake
- **OpenSearch**: Search e analytics
- **DuckDB**: Analytics engine
- **Docker**: Containerização