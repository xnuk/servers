import {
  provider = aws.global
  to       = aws_cloudfront_distribution.file
  id       = "E25NIXAMJCPQR7"
}

resource "aws_cloudfront_distribution" "file" {
  provider = aws.global
  enabled  = true

  aliases = ["file.xnu.kr"]
  comment = "file.xnu.kr"

  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.file.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.file.bucket_regional_domain_name

    origin_access_control_id = "E2S2O8VGGW4WSM"
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

    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    response_headers_policy_id = "064181a2-6b87-4b1b-8a02-3241e7e8a622"
    target_origin_id           = aws_s3_bucket.file.bucket_regional_domain_name
    viewer_protocol_policy     = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:734786202020:certificate/14262309-2719-4b88-bce6-c3477be889df"
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

}

