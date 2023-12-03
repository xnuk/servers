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

