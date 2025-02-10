########################################
# Data sources
########################################

# Computed variables
locals {
  region_tag = {
    "us-east-1" = "use1"
    "us-east-2" = "use2"
    "us-west-1" = "usw1"
  }

  #######################################
  # Terraform State S3 Bucket
  #######################################
  bucket_name = "s3-${local.region_tag[var.region]}-${lower(var.app_name)}-${var.env}-backend"
  acl         = "private"
  tags = merge(
    var.tags,
    tomap({
      "Name" = local.bucket_name
    }),
  )


  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"
  versioning = {
    enabled = var.versioning_enabled
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  #######################################
  # Dynamodb for TF state locking
  #######################################
  dynamodb_name = "dynamo-${local.region_tag[var.region]}-${lower(var.app_name)}-${var.env}-terraform-state-lock"

}

# Current account ID
data "aws_caller_identity" "this" {}

# S3 Bucket Policy
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
      ]
    }

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
      ]
    }

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }
}