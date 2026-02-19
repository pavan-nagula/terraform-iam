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
  name               = "test_role"
  assume_role_policy = data.aws_iam_policy_document.trust_ec2_lambda.json

  #   # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  #   assume_role_policy = jsonencode({
  #     Version = "2012-10-17"
  #     Statement = [
  #       {
  #         Sid       = "EC2AssumeRole"
  #         Effect    = "Allow"
  #         Action    = "sts:AssumeRole"
  #         Principal = { Service = "ec2.amazonaws.com" }
  #       },
  #       {
  #         Sid       = "LambdaAssumeRole"
  #         Effect    = "Allow"
  #         Action    = "sts:AssumeRole"
  #         Principal = { Service = "lambda.amazonaws.com" }
  #       }
  #     ]

  #   })

  tags = {
    tag-key = "tag-value"
  }
}

//Attaching AmazonS3ReadOnlyAccess to the test-role
resource "aws_iam_role_policy_attachment" "attach_s3_readonly" {
  role       = aws_iam_role.test_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# How to use this role with an EC2 instance
# You don’t attach a role directly to EC2. You create an Instance Profile, then attach that to the instance.

# # 1) Instance profile wraps the role for EC2
# resource "aws_iam_instance_profile" "test_profile" {
#   name = "test_profile"
#   role = aws_iam_role.test_role.name
# }

# # 2) EC2 instance using the profile (simplified example)
# resource "aws_instance" "web" {
#   ami           = "ami-xxxxxxxx"   # put a valid AMI ID for your region
#   instance_type = "t2.micro"

#   iam_instance_profile = aws_iam_instance_profile.test_profile.name
# }
