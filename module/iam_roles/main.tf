provider "aws" {
  region = "us-east-1"
}

# 1) TRUST POLICY: EC2 and Lambda can assume this role (two separate statements for clarity)
data "aws_iam_policy_document" "trust_ec2_lambda" {
  statement {
    sid     = "EC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# 2) ROLE: defining the role and attaching the trust policy
resource "aws_iam_role" "test_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust_ec2_lambda.json

  tags = {
    tag-key = "tag-value"
  }
}

//Attaching AmazonS3ReadOnlyAccess to the test-role
resource "aws_iam_role_policy_attachment" "attach_s3_readonly" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
