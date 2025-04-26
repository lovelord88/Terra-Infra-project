resource "aws_lb" "main" {
  name                       = "${var.name}-ecs"
  subnets                    = split(",", nonsensitive(data.aws_ssm_parameter.public_subnets.value))
  security_groups            = [aws_security_group.lb_sg.id]
  load_balancer_type         = "application"
  idle_timeout               = "300"
  enable_waf_fail_open       = true
  enable_deletion_protection = false
  internal                   = false
  depends_on = [
    aws_security_group.lb_sg
  ]
}

resource "aws_lb_target_group" "app" {
  name                          = "${var.name}-ecs-tg"
  port                          = var.app_port
  protocol                      = "HTTP"
  vpc_id                        = data.aws_ssm_parameter.vpc_id.value
  target_type                   = "ip"
  load_balancing_algorithm_type = "least_outstanding_requests"

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "120"
    path                = var.health_check_path
    unhealthy_threshold = "5"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
    }
  }
}


resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = data.aws_acm_certificate.tls_cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.app.arn
    type             = "forward"
  }
}
