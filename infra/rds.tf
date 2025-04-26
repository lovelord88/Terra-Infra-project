resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "_-#%&"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  description                    = "Secrets for RDS SQL Server including credentials and endpoint"
  name                           = "vivienneDotsey/db_credentials"
  force_overwrite_replica_secret = true
  recovery_window_in_days        = 0
}

resource "aws_secretsmanager_secret_version" "db_credentials_val" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = module.rds_sqlserver.db_admin_username
    password = module.rds_sqlserver.db_admin_password
    endpoint = module.rds_sqlserver.db_instance_endpoint
  })
}

module "rds_sqlserver" {
  source                = "../tf-modules/tf-aws-mssql-rds"
  name                  = "vivienneDotsey"
  mssql_admin_username  = "vivienneDotsey"
  mssql_admin_password  = random_password.master.result
  rds_allocated_storage = 20
  storage_type          = "gp3"
  rds_instance_class    = "db.t3.small"
  vpc_id                = data.aws_ssm_parameter.vpc_id.value
  private_subnet_ids    = split(",", data.aws_ssm_parameter.private_subnets.value)
  vpc_cidr_blocks       = [data.aws_ssm_parameter.vpc_cidr.value]
  vpc_cidr_blocks_vpn   = [data.aws_ssm_parameter.vpn_cidr.value]
  s3_bucket             = aws_s3_bucket.rds_export_bucket.id
  engine                = "sqlserver-ex"
  rds_multi_az          = false
  storage_encrypted     = false
  tags                  = var.tags
}

###########################################################
# Export bucket
###########################################################
resource "aws_s3_bucket" "rds_export_bucket" {
  bucket        = "prod-viviennedotsey-rds-export-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "rds_export_bucket" {
  bucket = aws_s3_bucket.rds_export_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "rds_export_bucket" {
  bucket = aws_s3_bucket.rds_export_bucket.id

  rule {
    id     = "rds_export_bucketLifecycleRule"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 15
      storage_class = "INTELLIGENT_TIERING"
    }

    transition {
      days          = 45
      storage_class = "ONEZONE_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }
  }
}

resource "aws_s3_bucket_public_access_block" "rds_export_bucket" {
  bucket = aws_s3_bucket.rds_export_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "rds_export_bucket" {
  bucket = aws_s3_bucket.rds_export_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
