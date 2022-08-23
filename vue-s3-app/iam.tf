locals {
  circleci_org_id     = "b167a5c2-762d-40bd-ace7-8ceece7d0d67"
  circleci_project_id = "ea75d0d0-64ec-4a9f-8665-5dd9e6f15d86"
  github = {
    org  = "tranChiVi0123"
    repo = "vue-s3-app"
  }
}

resource "aws_iam_openid_connect_provider" "circleci" {
  url            = "https://oidc.circleci.com/org/${local.circleci_org_id}"
  client_id_list = [local.circleci_org_id]
  thumbprint_list = [
    # CircleCIのOIDC プロバイダーのサムプリント。固定値。
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",
  ]
}

data "aws_iam_policy_document" "assume_cirleci" {
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
}

resource "aws_iam_role" "circleci" {
  name               = "circleci"
  description        = "Connect from by oidc"
  assume_role_policy = data.aws_iam_policy_document.assume_cirleci.json
}

resource "aws_iam_role_policy_attachment" "circleci" {
  role       = aws_iam_role.circleci.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
