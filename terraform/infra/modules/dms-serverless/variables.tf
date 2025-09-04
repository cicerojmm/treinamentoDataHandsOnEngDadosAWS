variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where DMS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for DMS replication subnet group"
  type        = list(string)
}

variable "source_endpoint_config" {
  description = "Source endpoint configuration"
  type = object({
    endpoint_id   = string
    engine_name   = string
    server_name   = string
    port          = number
    database_name = string
    username      = string
    password      = string
  })
}

variable "target_s3_config" {
  description = "Target S3 configuration"
  type = object({
    bucket_name = string
    bucket_folder = string
  })
}

variable "replication_config" {
  description = "Replication configuration"
  type = object({
    replication_config_id = string
    source_endpoint_arn   = string
    target_endpoint_arn   = string
    table_mappings        = string
    compute_config = object({
      max_capacity_units = number
    })
  })
  default = null
}

variable "table_mappings" {
  description = "Table mappings for DMS replication"
  type        = string
  default     = ""
}

variable "replication_subnet_group_id" {
  description = "ID of the existing DMS replication subnet group"
  type        = string
}