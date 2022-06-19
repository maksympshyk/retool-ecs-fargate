resource "random_string" "db_password" {
  length  = 12
  special = false
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.deployment_name}-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_string.db_password.result

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "random_string" "jwt_secret" {
  length  = 12
  special = false
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "${var.deployment_name}-jwt-secret"
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = random_string.jwt_secret.result

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "random_string" "encryption_key" {
  length  = 12
  special = false
}

resource "aws_secretsmanager_secret" "encryption_key" {
  name = "${var.deployment_name}-encryption-key"
}

resource "aws_secretsmanager_secret_version" "encryption_key" {
  secret_id     = aws_secretsmanager_secret.encryption_key.id
  secret_string = random_string.encryption_key.result

  lifecycle {
    ignore_changes = [secret_string]
  }
}
