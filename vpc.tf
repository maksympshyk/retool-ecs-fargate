data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_vpc" "target" {
  id = var.target_vpc_id
}
