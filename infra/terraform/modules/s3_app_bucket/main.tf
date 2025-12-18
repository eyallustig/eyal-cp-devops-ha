resource "aws_s3_bucket" "payload" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "payload" {
  bucket                  = aws_s3_bucket.payload.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "payload" {
  bucket = aws_s3_bucket.payload.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "payload" {
  bucket = aws_s3_bucket.payload.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "payload" {
  bucket = aws_s3_bucket.payload.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "payload" {
  bucket = aws_s3_bucket.payload.id

  rule {
    id     = "expire-current-objects"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.object_expiration_days
    }
  }

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.payload]
}

data "aws_iam_policy_document" "tls_only" {
  count = var.enforce_tls ? 1 : 0

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.payload.arn,
      "${aws_s3_bucket.payload.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "payload" {
  count  = var.enforce_tls ? 1 : 0
  bucket = aws_s3_bucket.payload.id
  policy = data.aws_iam_policy_document.tls_only[0].json
}
