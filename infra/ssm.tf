# Store VPN CIDR in SSM Parameter Store
resource "aws_ssm_parameter" "vpn_cidr" {
  name = "/account/eun1/vpn/vpn_cidr"
  type = "SecureString"

  value = var.vpn_cidr
}

resource "aws_ssm_parameter" "vpc_id" {
  name = "/account/eun1/vpc/id"
  type = "SecureString"

  value = module.vpc.vpc_id
}

resource "aws_ssm_parameter" "vpc_cidr" {
  name = "/account/eun1/vpc/cidr"
  type = "String"

  value = module.vpc.vpc_cidr_block
}

resource "aws_ssm_parameter" "public_subnets" {
  name  = "/account/eun1/vpc/public_subnet/ids"
  type  = "StringList"
  value = join(",", module.vpc.public_subnets)
}

resource "aws_ssm_parameter" "private_subnets" {
  name  = "/account/eun1/vpc/private_subnet/ids"
  type  = "StringList"
  value = join(",", module.vpc.private_subnets)
}