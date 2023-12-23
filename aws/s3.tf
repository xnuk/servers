import {
  provider = aws.seoul
  to       = aws_s3_bucket.file
  id       = "file.xnu.kr"
}

import {
  provider = aws.seoul
  to       = aws_s3_bucket.kobis
  id       = "kobis.xnu.kr"
}

import {
  provider = aws.seoul
  to       = aws_s3_bucket.trunk
  id       = "trunk.xnu.kr"
}

import {
  provider = aws.seoul
  to       = aws_s3_bucket.trunk-gotosocial
  id       = "trunk.xnu.kr-gotosocial"
}

import {
  provider = aws.seoul
  to       = aws_s3_bucket.www
  id       = "www.xnu.kr"
}

locals {
  s3-meta = {
    file = {
      s3         = aws_s3_bucket.file
      cloudfront = aws_cloudfront_distribution.file
    }
    kobis = {
      s3         = aws_s3_bucket.kobis
      cloudfront = aws_cloudfront_distribution.kobis
    }
    trunk = {
      s3         = aws_s3_bucket.trunk
      cloudfront = aws_cloudfront_distribution.trunk
    }
    trunk-gotosocial = {
      s3         = aws_s3_bucket.trunk-gotosocial
      cloudfront = aws_cloudfront_distribution.trunk
    }
    www = {
      s3         = aws_s3_bucket.www
      cloudfront = aws_cloudfront_distribution.www
    }
  }
}


resource "aws_s3_bucket" "file" {
  provider = aws.seoul
  bucket   = "file.xnu.kr"
}

data "aws_iam_policy_document" "s3-cloudfront-policies" {
  for_each = local.s3-meta

  statement {
    sid    = "CloudfrontConnectionManagedByTerraform"
    effect = "Allow"

    principals {
      # TODO: "www" uses OAI (legacy)
      type = each.key == "www" ? "AWS" : "Service"
      identifiers = (
        each.key == "www"
        ? ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E2G9C35NHLB4O4"]
        : ["cloudfront.amazonaws.com"]
      )
    }

    actions   = ["s3:GetObject"]
    resources = ["${each.value.s3.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [each.value.cloudfront.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "policies" {
  for_each = local.s3-meta

  provider = aws.seoul
  bucket   = each.value.s3.bucket
  policy   = data.aws_iam_policy_document.s3-cloudfront-policies[each.key].json
}

resource "aws_s3_bucket_public_access_block" "make-private" {
  for_each = local.s3-meta

  provider = aws.seoul
  bucket   = each.value.s3.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "kobis" {
  provider = aws.seoul
  bucket   = "kobis.xnu.kr"
}

resource "aws_s3_bucket" "trunk" {
  provider = aws.seoul
  bucket   = "trunk.xnu.kr"
}

resource "aws_s3_bucket" "trunk-gotosocial" {
  provider = aws.seoul
  bucket   = "trunk.xnu.kr-gotosocial"
}

resource "aws_s3_bucket" "www" {
  provider = aws.seoul
  bucket   = "www.xnu.kr"
}

