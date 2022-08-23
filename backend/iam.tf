data "aws_caller_identity" "current" {}

locals {
  principal_arns      = var.principal_arns != null ? var.principal_arns : [data.aws_caller_identity.current.arn]
  circleci_org_id     = "b167a5c2-762d-40bd-ace7-8ceece7d0d67"
  circleci_project_id = "ea75d0d0-64ec-4a9f-8665-5dd9e6f15d86"
}

data "aws_iam_policy_document" "policy_doc" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.circleci.arn]
    }

    condition {
      test     = "StringLike"
      variable = "oidc.circleci.com/org/${local.circleci_org_id}:sub"
      values   = ["org/${local.circleci_org_id}/project/${local.circleci_project_id}/user/*"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.s3_bucket.arn]
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]
  }

  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = [aws_dynamodb_table.dynamo_db.arn]
  }
}

resource "aws_iam_openid_connect_provider" "circleci" {
  url            = "https://oidc.circleci.com/org/${local.circleci_org_id}"
  client_id_list = [local.circleci_project_id]
  thumbprint_list = [
    # CircleCIのOIDC プロバイダーのサムプリント。固定値。
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",
  ]
}

# resource "aws_iam_policy" "policy" {
#   name   = "${title(var.project)}S3BackendPolicy"
#   path   = "/"
#   policy = data.aws_iam_policy_document.policy_doc.json
# }

resource "aws_iam_role" "iam_role" {
  name               = "${title(var.project)}S3BackendRole"
  assume_role_policy = data.aws_iam_policy_document.policy_doc.json

  # assume_role_policy = <<-EOF
  # {
  #   "Version": "2012-10-17",
  #   "Statement": [
  #     {
  #       "Action": "sts:AssumeRole",
  #       "Principal": {
  #         "AWS": ${jsonencode(local.principal_arns)}
  #       },
  #       "Effect": "Allow"
  #     }
  #   ]
  # }
  # EOF

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role = aws_iam_role.iam_role.name
  # policy_arn = aws_iam_policy.policy.arn
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
