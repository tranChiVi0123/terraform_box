resource "aws_s3_bucket" "mfx_marketing_lp" {
  bucket_prefix = "${var.environment}-marketing-lp-front"
}

resource "aws_s3_bucket_acl" "mfx_marketing_lp" {
  bucket = aws_s3_bucket.mfx_marketing_lp.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "mfx_marketing_lp" {
  bucket = aws_s3_bucket.mfx_marketing_lp.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
