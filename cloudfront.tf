resource "aws_cloudfront_distribution" "s3-distribution" {
  origin {
    domain_name = aws_s3_bucket.app.bucket_regional_domain_name
    # origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id = random_integer.origin_id.result
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront-logging.bucket_domain_name
    prefix          = local.prefix
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = random_integer.origin_id.result

    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id = aws_cloudfront_cache_policy.neo-cloudfront-cache-policy.id
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

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

### Logging bucket
resource "aws_s3_bucket" "cloudfront-logging" {
  bucket = "${local.prefix}-cloudfront-logging-${random_integer.bucket_suffix.result}"
}

resource "aws_s3_bucket_ownership_controls" "cloudfront-logging" {
  bucket = aws_s3_bucket.cloudfront-logging.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront-logging" {
  bucket = aws_s3_bucket.cloudfront-logging.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.cloudfront-logging
  ]
}