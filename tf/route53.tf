resource "aws_route53_zone" "my_private_zone" {
  name    = var.aws_route53_local_domain
  comment = "Hosted zone for backend svcs"

  vpc {
    vpc_id     = module.my_vpc.vpc_id
    vpc_region = var.aws_region
  }
}

resource "aws_route53_record" "db_route53_record" {
  zone_id = aws_route53_zone.my_private_zone.zone_id
  name    = "db01.${var.aws_route53_local_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.db_svc.private_ip]
}

resource "aws_route53_record" "mc_route53_record" {
  zone_id = aws_route53_zone.my_private_zone.zone_id
  name    = "mc01.${var.aws_route53_local_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.memcached_svc.private_ip]
}

resource "aws_route53_record" "rmq_route53_record" {
  zone_id = aws_route53_zone.my_private_zone.zone_id
  name    = "rmq01.${var.aws_route53_local_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.rabbitmq_svc.private_ip]
}