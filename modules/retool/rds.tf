resource "aws_db_subnet_group" "db" {
  name       = "${var.deployment_name}-db"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "db" {
  identifier                   = "${var.deployment_name}-db-instance"
  allocated_storage            = 80
  instance_class               = var.db_instance_class
  engine                       = "postgres"
  engine_version               = "11.12"
  db_name                      = local.db_name
  username                     = local.db_username
  password                     = aws_secretsmanager_secret_version.db_password.secret_string
  port                         = 5432
  publicly_accessible          = false
  db_subnet_group_name         = aws_db_subnet_group.db.name
  vpc_security_group_ids       = [aws_security_group.db.id]
  performance_insights_enabled = true
  storage_encrypted            = true
  deletion_protection          = true
}

resource "aws_security_group" "db" {
  name   = "${var.deployment_name}-db"
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.retool.id]
  }

  tags = {
    Name = "${var.deployment_name}-db"
  }
}
