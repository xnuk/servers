import {
  to       = aws_acm_certificate.xnu_kr
  id       = "arn:aws:acm:us-east-1:734786202020:certificate/14262309-2719-4b88-bce6-c3477be889df"
  provider = aws.global
}

resource "aws_acm_certificate" "xnu_kr" {
  provider    = aws.global
  domain_name = "*.xnu.kr"

  tags = {
    "amazon" = "2"
  }
  tags_all = {
    "amazon" = "2"
  }
}
