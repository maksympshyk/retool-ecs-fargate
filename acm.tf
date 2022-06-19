resource "aws_acm_certificate" "retool" {
  domain_name               = var.domain_name
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.domain_name
  }
}

resource "aws_route53_record" "retool_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.retool.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "300"

  zone_id = var.zone_id
}

resource "aws_acm_certificate_validation" "retool" {
  certificate_arn         = aws_acm_certificate.retool.arn
  validation_record_fqdns = [for record in aws_route53_record.retool_cert_validation : record.fqdn]
}
