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
