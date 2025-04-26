resource "aws_route53_record" "www-live" {
  zone_id = data.aws_route53_zone.primary_zone_id.id
  name    = var.dns_record_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.main.dns_name]
}