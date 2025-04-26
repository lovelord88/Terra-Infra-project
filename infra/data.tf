data "aws_ssm_parameter" "vpc_id" {
  name = "/account/eun1/vpc/id"

  depends_on = [aws_ssm_parameter.vpc_id]
}

data "aws_ssm_parameter" "vpc_cidr" {
  name = "/account/eun1/vpc/cidr"

  depends_on = [aws_ssm_parameter.vpc_cidr]
}

data "aws_ssm_parameter" "public_subnets" {
  name = "/account/eun1/vpc/public_subnet/ids"

  depends_on = [aws_ssm_parameter.public_subnets]
}

data "aws_ssm_parameter" "private_subnets" {
  name = "/account/eun1/vpc/private_subnet/ids"

  depends_on = [aws_ssm_parameter.private_subnets]
}

data "aws_acm_certificate" "tls_cert" {
  domain   = var.dns_record_name
  statuses = ["ISSUED"]
  types    = ["AMAZON_ISSUED"]
}

data "aws_route53_zone" "primary_zone_id" {
  name = var.domain_name

  private_zone = false
}

# Get current Account ID
data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "vpn_cidr" {
  name = "/account/eun1/vpn/vpn_cidr"

  depends_on = [aws_ssm_parameter.vpn_cidr]
}