output "source_endpoint_arn" {
  description = "ARN of the source endpoint"
  value       = aws_dms_endpoint.source.endpoint_arn
}

output "target_endpoint_arn" {
  description = "ARN of the target endpoint"
  value       = aws_dms_endpoint.target.endpoint_arn
}

output "replication_task_arn" {
  description = "ARN of the replication task"
  value       = aws_dms_replication_task.main.replication_task_arn
}

output "replication_instance_arn" {
  description = "ARN of the replication instance"
  value       = aws_dms_replication_instance.main.replication_instance_arn
}

output "replication_subnet_group_id" {
  description = "ID of the replication subnet group"
  value       = var.replication_subnet_group_id
}

output "dms_access_role_arn" {
  description = "ARN of the DMS access role"
  value       = aws_iam_role.dms_access_for_endpoint.arn
}