variable "name" {
  description = "A unique name used as a prefix for the resources."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "rds_allocated_storage" {
  description = "The allocated storage in gigabytes for the RDS instance."
  type        = number
}

variable "rds_instance_class" {
  description = "The instance type of the RDS instance."
  type        = string
}

variable "rds_multi_az" {
  description = "Specifies if the RDS instance is deployed across multiple availability zones for high availability."
  type        = bool
}

variable "mssql_admin_username" {
  description = "Username for the administrator DB user."
  type        = string
}

variable "mssql_admin_password" {
  description = "Password for the administrator DB user."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of VPC subnet identifiers where the RDS instance will be located."
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC identifier where security groups and RDS instance will be created."
  type        = string
}

variable "vpc_cidr_blocks" {
  description = "List of CIDR blocks that will be granted access to the MSSQL instance."
  type        = list(string)
}

variable "vpc_cidr_blocks_vpn" {
  description = "List of CIDR blocks for VPN access to the MSSQL instance."
  type        = list(string)
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. Set to 'true' to skip creating a final snapshot."
  type        = bool
  default     = true
}

variable "rds_max_allocated_storage" {
  description = "When configured, the upper limit to which Amazon RDS can automatically scale the storage"
  type        = number
  default     = 2000
}

variable "s3_bucket" {
  description = "S3 bucket name used by the DB log shipping"
}

variable "engine" {
  description = "The MSSQL engine type"
}

variable "storage_encrypted" {
  description = "Whether the DB instance is encrypted"
}

variable "storage_type" {
  description = "The storage type to use for the DB instance. eg. gp2 or gp3"
}

# variable "vpc_name" {
#   description = "Name of the VPC"
#   type        = string
# }

# variable "vpc_cidr" {
#   description = "CIDR block for the VPC"
#   type        = string
# }

# variable "public_subnets" {
#   description = "List of public subnet CIDRs"
#   type        = list(string)
# }

# variable "private_subnets" {
#   description = "List of private subnet CIDRs"
#   type        = list(string)
# }

# variable "account" {
#   description = "AWS account name or ID (used for parameter naming)"
#   type        = string
# }

# variable "region" {
#   description = "AWS region"
#   type        = string
# }



# variable "vpn_cidr" {
#   description = "The client IPv4 CIDR range for the VPN connection"
#   type        = string
# }

# variable "client_root_cert_arn" {
#   description = "The ARN of the client root certificate"
#   type        = string
# }



