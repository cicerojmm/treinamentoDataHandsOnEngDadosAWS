#IAM Role for DMS
resource "aws_iam_role" "dms_access_for_endpoint" {
  name = "dms-access-for-endpoint-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "dms-access-for-endpoint-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "dms_access_for_endpoint" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  role       = aws_iam_role.dms_access_for_endpoint.name
}

# IAM Role for DMS VPC
resource "aws_iam_role" "dms_vpc_role" {
  name = "dms-vpc-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "dms-vpc-role-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "dms_vpc_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
  role       = aws_iam_role.dms_vpc_role.name
}

# Source Endpoint (PostgreSQL)
resource "aws_dms_endpoint" "source" {
  endpoint_id   = var.source_endpoint_config.endpoint_id
  endpoint_type = "source"
  engine_name   = var.source_endpoint_config.engine_name
  server_name   = var.source_endpoint_config.server_name
  port          = var.source_endpoint_config.port
  database_name = var.source_endpoint_config.database_name
  username      = var.source_endpoint_config.username
  password      = var.source_endpoint_config.password

  tags = {
    Name        = "dms-source-endpoint-${var.environment}"
    Environment = var.environment
  }
}

# Target Endpoint (S3)
resource "aws_dms_endpoint" "target" {
  endpoint_id   = "s3-target-${var.environment}"
  endpoint_type = "target"
  engine_name   = "s3"

  s3_settings {
    bucket_name             = var.target_s3_config.bucket_name
    bucket_folder           = var.target_s3_config.bucket_folder
    compression_type        = "GZIP"
    data_format             = "parquet"
    service_access_role_arn = aws_iam_role.dms_access_for_endpoint.arn
  }

  tags = {
    Name        = "dms-target-endpoint-${var.environment}"
    Environment = var.environment
  }
}

# DMS Replication Task
resource "aws_dms_replication_task" "main" {
  replication_task_id       = "postgres-to-s3-${var.environment}"
  source_endpoint_arn       = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.target.endpoint_arn
  replication_instance_arn  = aws_dms_replication_instance.main.replication_instance_arn
  migration_type            = "full-load-and-cdc"
  table_mappings            = var.table_mappings

  tags = {
    Name        = "dms-replication-task-${var.environment}"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.dms_access_for_endpoint,
    aws_iam_role_policy_attachment.dms_vpc_role
  ]
}

# DMS Replication Instance
resource "aws_dms_replication_instance" "main" {
  replication_instance_id   = "dms-instance-${var.environment}"
  replication_instance_class = "dms.t3.micro"
  replication_subnet_group_id = var.replication_subnet_group_id
  
  tags = {
    Name        = "dms-instance-${var.environment}"
    Environment = var.environment
  }
}