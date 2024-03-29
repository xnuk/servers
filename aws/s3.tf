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
      versioning = true
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
      s3 = aws_s3_bucket.www
    }
  }
}


resource "aws_s3_bucket" "file" {
  provider = aws.seoul
  bucket   = "file.xnu.kr"
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

data "aws_iam_policy_document" "s3-cloudfront-policies" {
  for_each = local.s3-meta

  statement {
    sid    = "CloudfrontConnectionManagedByTerraform"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${each.value.s3.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = (
        contains(keys(each.value), "cloudfront")
        ? [each.value.cloudfront.arn] : []
      )
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

resource "aws_s3_bucket_versioning" "versionings" {
  for_each = local.s3-meta

  bucket   = each.value.s3.bucket
  provider = aws.seoul
  versioning_configuration {
    status = (
      (
        contains(keys(each.value), "versioning")
        ? each.value.versioning : false
      )
      ? "Enabled" : "Disabled"
    )
  }
}

resource "aws_s3_bucket_ownership_controls" "ownerships" {
  for_each = local.s3-meta
  bucket   = each.value.s3.bucket
  provider = aws.seoul

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
