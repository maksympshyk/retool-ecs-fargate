locals {
  db_name     = "hammerhead_production"
  db_username = "retool_user"
  environment_variables = concat(var.additional_env_vars, [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "POSTGRES_DB"
      value = local.db_name
    },
    {
      name  = "POSTGRES_HOST"
      value = aws_db_instance.db.address
    },
    {
      name  = "POSTGRES_SSL_ENABLED"
      value = "true"
    },
    {
      name  = "POSTGRES_PORT"
      value = "5432"
    },
    {
      "name"  = "POSTGRES_USER",
      "value" = local.db_username
    },
    {
      "name"  = "POSTGRES_PASSWORD",
      "value" = aws_secretsmanager_secret_version.db_password.secret_string
    },
    {
      "name" : "JWT_SECRET",
      "value" : aws_secretsmanager_secret_version.jwt_secret.secret_string
    },
    {
      "name" : "ENCRYPTION_KEY",
      "value" : aws_secretsmanager_secret_version.encryption_key.secret_string
    },
    {
      "name" : "LICENSE_KEY",
      "value" : var.license_key
    }
    ]
  )
}
