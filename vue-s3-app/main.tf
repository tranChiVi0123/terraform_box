provider "aws" {
  region = var.region
}

# comment test
data "aws_region" "current" {}
locals {
  tags = {
    project = var.project
  }
}

output "config" {
  value = {
    bucket      = aws_s3_bucket.mfx_marketing_lp.bucket
    region      = data.aws_region.current.name
    role_arn    = aws_iam_role.circleci.arn
  }
}
