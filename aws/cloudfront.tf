import {
  provider = aws.global
  to       = aws_cloudfront_distribution.file
  id       = "E25NIXAMJCPQR7"
}

import {
  provider = aws.global
  to       = aws_cloudfront_origin_access_control.file
  id       = "E2S2O8VGGW4WSM"
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}



## < Response header policies > ##

resource "aws_cloudfront_response_headers_policy" "s_xnu_kr" {
  provider = aws.global
  name     = "s-xnu-kr"

  security_headers_config {
    referrer_policy {
      override        = true
      referrer_policy = "no-referrer"
    }

    strict_transport_security {
      access_control_max_age_sec = 94672800
      include_subdomains         = true
      override                   = true
      preload                    = true
    }
  }
}


resource "aws_cloudfront_response_headers_policy" "hsts_noreferrer_policy" {
  provider = aws.global
  comment  = "HSTS + noreferrer"
  name     = "hsts-noreferrer-policy"

  security_headers_config {
    referrer_policy {
      override        = false
      referrer_policy = "no-referrer"
    }
    strict_transport_security {
      access_control_max_age_sec = 94672800
      include_subdomains         = true
      override                   = true
      preload                    = true
    }
  }
}


resource "aws_cloudfront_response_headers_policy" "hsts" {
  provider = aws.global
  name     = "HSTS"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 94672800
      include_subdomains         = true
      override                   = true
      preload                    = true
    }
  }
}


## </ Response header policies > ##



resource "aws_cloudfront_distribution" "file" {
  provider = aws.global
  enabled  = true

  aliases = ["file.xnu.kr"]
  comment = "file.xnu.kr"

  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.file.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.file.bucket_regional_domain_name

    origin_access_control_id = aws_cloudfront_origin_access_control.file.id
  }

  default_root_object = "/404"

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = "403"
    response_code         = "404"
    response_page_path    = "/404"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = "404"
    response_code         = "404"
    response_page_path    = "/404"
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = "true"

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.s_xnu_kr.id
    target_origin_id           = aws_s3_bucket.file.bucket_regional_domain_name
    viewer_protocol_policy     = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.xnu_kr.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "file" {
  provider = aws.global

  name        = aws_s3_bucket.file.bucket_regional_domain_name
  description = ""

  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

