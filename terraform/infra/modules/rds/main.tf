resource "aws_db_parameter_group" "postgres" {
  family = "postgres17"
  name   = "${var.environment}-postgres-pg"
}

resource "aws_db_subnet_group" "postgres" {
  name       = "${var.environment}-postgres-subnet-group"
  subnet_ids = var.public_subnet_ids

  tags = {
    Name        = "${var.environment}-postgres-subnet-group"
    Environment = var.environment
  }
}

resource "aws_security_group" "postgres" {
  name_prefix = "${var.environment}-postgres-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-postgres-sg"
    Environment = var.environment
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "datahandson-engdados-${var.environment}-postgres"
  engine         = "postgres"
  engine_version = "17.5"
  instance_class = var.instance_class
  
  allocated_storage = var.allocated_storage
  storage_type      = "gp2"
  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  
  parameter_group_name   = aws_db_parameter_group.postgres.name
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  publicly_accessible    = true
  
  skip_final_snapshot = true
  deletion_protection = false
  
  tags = {
    Name        = "${var.environment}-postgres"
    Environment = var.environment
  }
}