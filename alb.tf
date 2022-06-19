resource "aws_security_group" "alb" {
  name   = "${var.deployment_name}-alb"
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.retool.id]
  }

  tags = {
    Name = "${var.deployment_name}-alb"
  }
}

resource "aws_lb" "alb" {
  load_balancer_type = "application"
  name               = "${var.deployment_name}-alb"

  security_groups = [aws_security_group.alb.id]
  subnets         = var.public_subnet_ids

  access_logs {
    bucket  = aws_s3_bucket.logs.bucket
    prefix  = "alb"
    enabled = true
  }

  depends_on = [
    aws_s3_bucket_policy.logs
  ]
}

resource "aws_lb_listener" "alb_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.retool.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_retool.arn
  }
}

resource "aws_lb_target_group" "alb_retool" {
  name   = "${var.deployment_name}-alb-retool"
  vpc_id = data.aws_vpc.main.id

  protocol    = "HTTP"
  target_type = "ip"
  port        = 3000

  health_check {
    interval            = 10
    path                = "/api/checkHealth"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}
