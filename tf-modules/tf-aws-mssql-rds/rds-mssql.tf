resource "aws_db_subnet_group" "default_rds_mssql" {
  name        = "netflix-rds-mssql-subnet-group"
  description = "The ${var.name} rds-mssql private subnet group."
  subnet_ids  = var.private_subnet_ids
}

resource "aws_security_group" "rds_mssql_security_group" {
  name        = "${var.name}-all-rds-mssql-internal"
  description = "${var.name} allow all vpc traffic to rds mssql."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_vpc_to_rds_mssql" {
  type              = "ingress"
  from_port         = 1433
  to_port           = 1433
  protocol          = "tcp"
  cidr_blocks       = var.vpc_cidr_blocks
  security_group_id = aws_security_group.rds_mssql_security_group.id
}

resource "aws_security_group_rule" "rds_mssql_security_group_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" // -1 means all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_mssql_security_group.id
}

resource "aws_security_group" "rds_mssql_security_group_vpn" {
  name        = "${var.name}-all-rds-mssql-vpn"
  description = "Allow all inbound traffic from vpn to rds mssql."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_vpn_to_rds_mssql" {
  type              = "ingress"
  from_port         = 1433
  to_port           = 1433
  protocol          = "tcp"
  cidr_blocks       = var.vpc_cidr_blocks_vpn
  security_group_id = aws_security_group.rds_mssql_security_group_vpn.id
}

resource "aws_security_group_rule" "rds_mssql_security_group_vpn_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" // -1 means all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_mssql_security_group_vpn.id
}

resource "aws_db_option_group" "rds_mssql_option_group" {
  name                     = "netflix-option-group"
  option_group_description = "${var.name} Option Group"
  engine_name              = "sqlserver-ex"
  major_engine_version     = "15.00"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.rds_nativebackup_role.arn
    }
  }
}

# ----------------------------------------------------------------
# Configurations for S3 backup
# ----------------------------------------------------------------
resource "aws_iam_role" "rds_enhanced_monitoring_role" {
  name = "rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "monitoring.rds.amazonaws.com",
      },
      Effect = "Allow",
      Sid    = "",
    }],
  })
}

resource "aws_iam_policy" "rds_enhanced_monitoring_policy" {
  name        = "rds-enhanced-monitoring-policy"
  description = "Policy for RDS Enhanced Monitoring"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup",
        "s3:*"
      ],
      Effect   = "Allow",
      Resource = "*",
    }],
  })
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring_role.name
  policy_arn = aws_iam_policy.rds_enhanced_monitoring_policy.arn
}

resource "aws_iam_role" "rds_nativebackup_role" {
  name = "rds-nativebackup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "rds.amazonaws.com",
      },
      Action = "sts:AssumeRole",
    }],
  })
}

resource "aws_iam_policy" "rds_nativebackup_policy" {
  name        = "rds-nativebackup-policy"
  description = "Policy for RDS Native Backup"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "s3:*"
      ],
      Effect   = "Allow",
      Resource = "*",
    }],
  })
}

resource "aws_iam_role_policy_attachment" "rds_nativebackup" {
  role       = aws_iam_role.rds_nativebackup_role.name
  policy_arn = aws_iam_policy.rds_nativebackup_policy.arn
}

# ----------------------------------------------------------------
# Create the DB Intance 
# ----------------------------------------------------------------
resource "aws_db_instance" "default_mssql" {
  identifier                   = "netflix"
  allocated_storage            = var.rds_allocated_storage
  max_allocated_storage        = var.rds_max_allocated_storage
  license_model                = "license-included"
  storage_type                 = var.storage_type
  engine                       = var.engine
  engine_version               = "15.00.4345.5.v1"
  instance_class               = var.rds_instance_class
  multi_az                     = var.rds_multi_az
  username                     = var.mssql_admin_username
  password                     = var.mssql_admin_password
  vpc_security_group_ids       = [aws_security_group.rds_mssql_security_group.id, aws_security_group.rds_mssql_security_group_vpn.id]
  db_subnet_group_name         = aws_db_subnet_group.default_rds_mssql.name
  backup_retention_period      = 3
  skip_final_snapshot          = var.skip_final_snapshot
  storage_encrypted            = var.storage_encrypted
  monitoring_interval          = 60
  performance_insights_enabled = true
  monitoring_role_arn          = aws_iam_role.rds_enhanced_monitoring_role.arn
  option_group_name            = aws_db_option_group.rds_mssql_option_group.name

  lifecycle {
    ignore_changes = [
      monitoring_interval
    ]
  }
}
