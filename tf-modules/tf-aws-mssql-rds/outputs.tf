# Output for Database Instance Endpoint
output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.default_mssql.endpoint
}

# Output for Database Instance ARN
output "db_instance_arn" {
  description = "The Amazon Resource Name (ARN) of the RDS instance."
  value       = aws_db_instance.default_mssql.arn
}

# Output for Database Instance Identifier
output "db_instance_identifier" {
  description = "The identifier of the RDS instance."
  value       = aws_db_instance.default_mssql.identifier
}

# Output for Subnet Group Name
output "db_subnet_group_name" {
  description = "The name of the database subnet group."
  value       = aws_db_subnet_group.default_rds_mssql.name
}

# Output for Primary VPC Security Group ID
output "primary_vpc_security_group_id" {
  description = "The ID of the primary VPC security group attached to the RDS instance."
  value       = aws_security_group.rds_mssql_security_group.id
}

# Output for VPN VPC Security Group ID
output "vpn_vpc_security_group_id" {
  description = "The ID of the VPN-specific VPC security group attached to the RDS instance."
  value       = aws_security_group.rds_mssql_security_group_vpn.id
}

# Output for Monitoring Role ARN
output "monitoring_role_arn" {
  description = "The ARN of the IAM role used for enhanced monitoring of the RDS instance."
  value       = aws_iam_role.rds_enhanced_monitoring_role.arn
}

# Output for Monitoring Policy ARN
output "monitoring_policy_arn" {
  description = "The ARN of the IAM policy attached to the monitoring role."
  value       = aws_iam_policy.rds_enhanced_monitoring_policy.arn
}

# Output for Database Engine Version
output "db_instance_engine_version" {
  description = "The engine version of the RDS database."
  value       = aws_db_instance.default_mssql.engine_version
}

# Output for Database Instance Status
output "db_instance_status" {
  description = "The current status of the RDS instance."
  value       = aws_db_instance.default_mssql.status
}

# Output for Database Admin Username
output "db_admin_username" {
  description = "The administrative username for the RDS database."
  value       = var.mssql_admin_username
  sensitive   = true
}

# Output for Database Admin Password
output "db_admin_password" {
  description = "The administrative password for the RDS database."
  value       = var.mssql_admin_password
  sensitive   = true
}
