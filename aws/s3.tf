import {
  provider = aws.seoul
  to       = aws_s3_bucket.file
  id       = "file.xnu.kr"
}

import {
  provider = aws.seoul
  to       = aws_s3_bucket_public_access_block.file
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


resource "aws_s3_bucket" "file" {
  provider = aws.seoul
  bucket   = "file.xnu.kr"
}

data "aws_iam_policy_document" "file_xnu_kr_policy" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.file.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.file.arn]
    }
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "file_policy" {
  provider = aws.seoul
  bucket   = aws_s3_bucket.file.id
  policy   = data.aws_iam_policy_document.file_xnu_kr_policy.json
}

resource "aws_s3_bucket_public_access_block" "file" {
  provider = aws.seoul
  bucket   = aws_s3_bucket.file.id

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

