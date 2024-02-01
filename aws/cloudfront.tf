import {
  provider = aws.global
  to       = aws_cloudfront_distribution.kobis
  id       = "E1IC6SA87SB9X3"
}

import {
  provider = aws.global
  to       = aws_cloudfront_distribution.trunk
  id       = "E1Z63U4GCWEG98"
}

import {
  provider = aws.global
  to       = aws_cloudfront_distribution.file
  id       = "E25NIXAMJCPQR7"
}

import {
  provider = aws.global
  to       = aws_cloudfront_distribution.s
  id       = "EJ5274NY7R80K"
}

import {
  provider = aws.global
  to       = aws_cloudfront_origin_access_control.file
  id       = "E2S2O8VGGW4WSM"
}

import {
  provider = aws.global
  to       = aws_cloudfront_origin_access_control.kobis
  id       = "EYEPS0STHQ49X"
}

import {
  provider = aws.global
  to       = aws_cloudfront_origin_access_control.trunk_gotosocial
  id       = "E2YOVHQ3Q71GA5"
}

import {
  provider = aws.global
  to       = aws_cloudfront_origin_access_control.trunk
  id       = "E35PJ5XJ6ZHDS3"
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


## < Access controls > ##


resource "aws_cloudfront_origin_access_control" "file" {
  provider = aws.global

  name        = aws_s3_bucket.file.bucket_regional_domain_name
  description = ""

  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_origin_access_control" "kobis" {
  provider = aws.global

  name        = aws_s3_bucket.kobis.bucket_regional_domain_name
  description = ""

  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_origin_access_control" "trunk" {
  provider = aws.global

  name        = "${aws_s3_bucket.trunk.bucket}-s3"
  description = "Accessing trunk.xnu.kr S3-Cloudfront"

  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_origin_access_control" "trunk_gotosocial" {
  provider = aws.global

  name        = "${aws_s3_bucket.trunk-gotosocial.bucket}-s3"
  description = "Accessing trunk.xnu.kr-gotosocial S3-Cloudfront"

  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


## </ Access controls > ##


## < Distributions > ##

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
    compress        = true

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

resource "aws_cloudfront_distribution" "kobis" {
  provider = aws.global
  enabled  = true

  aliases = ["kobis.xnu.kr"]

  http_version    = "http2and3"
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.hsts_noreferrer_policy.id
    target_origin_id           = "kobis.xnu.kr" # TODO
    viewer_protocol_policy     = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern = "/api/theaters/*"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.hsts_noreferrer_policy.id
    target_origin_id           = "kobis.xnu.kr"
    viewer_protocol_policy     = "redirect-to-https"
  }

  origin {
    domain_name              = aws_s3_bucket.kobis.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.kobis.id
    origin_id                = "kobis.xnu.kr" # TODO
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.xnu_kr.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_distribution" "s" {
  provider = aws.global
  aliases  = ["s.xnu.kr"]
  enabled  = true

  is_ipv6_enabled = true
  http_version    = "http2"
  price_class     = "PriceClass_200"

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.s_xnu_kr.id
    target_origin_id           = aws_s3_bucket.file.bucket_regional_domain_name
    viewer_protocol_policy     = "redirect-to-https"

    lambda_function_association {
      event_type   = "origin-request"
      include_body = true
      lambda_arn   = "arn:aws:lambda:us-east-1:734786202020:function:shortener-r1:17"
    }
  }

  origin {
    domain_name = aws_s3_bucket.file.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.file.bucket_regional_domain_name

    # This OAC does NOT allow accessing from s.xnu.kr
    # But, it's okay since s.xnu.kr don't need to access the origin.
    # Maybe I need to make dedicated /dev/null-like s3 bucket, in near future?
    origin_access_control_id = aws_cloudfront_origin_access_control.file.id
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.xnu_kr.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_distribution" "trunk" {
  provider = aws.global
  aliases  = ["trunk.xnu.kr"]
  enabled  = true

  http_version    = "http2and3"
  is_ipv6_enabled = true
  price_class     = "PriceClass_200"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.hsts_noreferrer_policy.id
    target_origin_id           = "trunk.xnu.kr"
    viewer_protocol_policy     = "https-only"
  }

  ordered_cache_behavior {
    path_pattern    = "/gotosocial/*"
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.hsts_noreferrer_policy.id
    target_origin_id           = "trunk.xnu.kr-gotosocial"
    viewer_protocol_policy     = "https-only"
  }

  origin {
    domain_name              = aws_s3_bucket.trunk-gotosocial.bucket_domain_name # not regional
    origin_access_control_id = aws_cloudfront_origin_access_control.trunk_gotosocial.id
    origin_id                = "trunk.xnu.kr-gotosocial"
  }

  origin {
    domain_name              = aws_s3_bucket.trunk.bucket_domain_name # not regional
    origin_access_control_id = aws_cloudfront_origin_access_control.trunk.id
    origin_id                = "trunk.xnu.kr"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.xnu_kr.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

## </ Distributions > ##
