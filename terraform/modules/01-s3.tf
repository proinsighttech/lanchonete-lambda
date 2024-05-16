resource "aws_s3_bucket" "raw_s3_bucket" {
  bucket = var.bucket_name
  tags = {
    "Environment" : var.environment
  }
}

resource "aws_s3_bucket_cors_configuration" "raw_s3_bucket" {
  bucket = aws_s3_bucket.raw_s3_bucket.id  

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }  
}

resource "aws_s3_bucket_acl" "raw_s3_bucket" {
    bucket = aws_s3_bucket.raw_s3_bucket.id
    acl    = "public-read"
    depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.raw_s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.raw_s3_bucket]
}

resource "aws_iam_user" "raw_s3_bucket" {
  name = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "raw_s3_bucket" {
  bucket = aws_s3_bucket.raw_s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "raw_s3_bucket" {
    bucket = aws_s3_bucket.raw_s3_bucket.id
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Sid = "PublicReadWriteObject"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
    ]
  })
  
  depends_on = [aws_s3_bucket_public_access_block.raw_s3_bucket]
}