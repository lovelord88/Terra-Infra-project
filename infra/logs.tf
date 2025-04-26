# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/${var.name}/ecs/app"
  retention_in_days = 30

  tags = {
    Name = "${var.name}-ecs-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "cb_log_stream" {
  name           = "${var.name}-ecs-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}
