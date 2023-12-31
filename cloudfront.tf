resource "aws_cloudfront_distribution" "s3-distribution" {
  origin {
    domain_name = aws_s3_bucket.app.bucket_regional_domain_name
    origin_id = random_integer.origin_id.result
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["${local.domain_prefix}.${data.aws_route53_zone.zone.name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = random_integer.origin_id.result

    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id = aws_cloudfront_cache_policy.neo-cloudfront-cache-policy.id
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront-logging.bucket_domain_name
    prefix          = "${local.prefix}-cloudfront"
  }

  http_version = "http2and3"

  depends_on = [ 
    aws_s3_bucket.cloudfront-logging,
    aws_acm_certificate.cert
  ]

}

resource "random_integer" "origin_id" {
  min = 10000000
  max = 99999999
}

resource "aws_cloudfront_cache_policy" "neo-cloudfront-cache-policy" {
  name        = "${local.prefix}-cache-policy"
  min_ttl     = 1
  default_ttl = 86400
  max_ttl     = 31536000

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

### Logging

resource "aws_s3_bucket" "cloudfront-logging" {
  bucket = "${local.prefix}-cloudfront-logs-${random_integer.bucket_suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "cloudfront-logging" {
  bucket = aws_s3_bucket.cloudfront-logging.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
