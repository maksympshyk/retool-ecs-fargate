resource "aws_security_group" "retool" {
  name   = "${var.deployment_name}-retool"
  vpc_id = data.aws_vpc.main.id

  tags = {
    Name = "${var.deployment_name}-retool"
  }
}

resource "aws_security_group_rule" "retool_to_http" {
  security_group_id = aws_security_group.retool.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "retool_to_https" {
  security_group_id = aws_security_group.retool.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "retool_to_ntp" {
  security_group_id = aws_security_group.retool.id
  type              = "egress"
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "retool_to_target_vpc" {
  security_group_id = aws_security_group.retool.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.target.cidr_block]
}

resource "aws_security_group_rule" "retool_from_alb" {
  security_group_id        = aws_security_group.retool.id
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "retool_to_db" {
  security_group_id        = aws_security_group.retool.id
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db.id
}
