data "aws_route53_zone" "zone" {
  name = "${var.dns_zone_name}"
}

resource "aws_route53_record" "neo" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${local.domain_prefix}.${data.aws_route53_zone.zone.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${local.domain_prefix}.${data.aws_route53_zone.zone.name}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  provider = aws.us-east-1
}

resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  ttl             = 60
  zone_id         = data.aws_route53_zone.zone.zone_id
  provider = aws.us-east-1
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
  provider = aws.us-east-1
}