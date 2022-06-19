variable "deployment_name" { default = "retool" }
variable "db_instance_class" { default = "db.t3.small" }
variable "retool_image" { default = "tryretool/backend:2.69.18" }
variable "vpc_id" {}
variable "target_vpc_id" {}
variable "zone_id" {}
variable "domain_name" {}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}
variable "wafv2_rule_group_arn" {}
variable "license_key" {}
variable "additional_env_vars" { default = [] }
