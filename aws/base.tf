terraform {
  required_version = "~> 1.6.0"

  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }

  cloud {
    organization = "Xnuk"
    workspaces { name = "aws" }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  alias  = "seoul"
}

provider "aws" {
  region = "us-east-1"
  alias  = "global"
}
