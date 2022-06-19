resource "aws_route53_record" "retool" {
  name    = var.domain_name
  type    = "A"
  zone_id = var.zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
  }
}
