# Hosted zone details
data "aws_route53_zone" "hosted_zone" {
  name = "agyapomaabonz.link"
}

# create a record set in route 53
resource "aws_route53_record" "site_domain" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "agyapomaabonz.link"
  type    = "A"

  alias {
    name                   = aws_lb.ecs-alb.dns_name
    zone_id                = aws_lb.ecs-alb.zone_id
    evaluate_target_health = true
  }
}