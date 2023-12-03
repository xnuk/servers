import {
  to       = aws_dynamodb_table.shortener
  id       = "Shortener"
  provider = aws.global
}

resource "aws_dynamodb_table" "shortener" {
  provider = aws.global
  name     = "Shortener"

  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "expire"
    type = "N"
  }
  attribute {
    name = "id"
    type = "S"
  }
  attribute {
    name = "url"
    type = "S"
  }

  global_secondary_index {
    hash_key           = "id"
    name               = "expire-index"
    non_key_attributes = []
    projection_type    = "KEYS_ONLY"
    range_key          = "expire"
  }

  global_secondary_index {
    hash_key           = "id"
    name               = "url-index"
    non_key_attributes = []
    projection_type    = "ALL"
    range_key          = "url"
  }
}

