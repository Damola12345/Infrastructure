provider "aws" {
  region  = "us-east-2"
  profile = "config"
}

resource "aws_config_config_rule" "ConfigRule" {
  name        = "required-tags"
  description = "A Config rule that checks whether your resources have the tags that you specify"
  depends_on  = [aws_lambda_permission.LambdaPermissionConfigRule]

  scope {
    compliance_resource_types = ["AWS::EC2::Instance"]
  }
  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = aws_lambda_function.LambdaFunctionConfigRule.arn
    source_detail {
      event_source = "aws.config"
      message_type = "ConfigurationItemChangeNotification"
    }
    source_detail {
      event_source = "aws.config"
      message_type = "OversizedConfigurationItemChangeNotification"
    }
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/index.zip"

  source {
    filename = "index.js"
    content  = "${file("${path.module}/index.js")}"

  }
}


resource "aws_lambda_function" "LambdaFunctionConfigRule" {
  function_name    = "LambdaFunctionEc2"
  timeout          = "300"
  runtime          = "nodejs14.x"
  handler          = "index.handler"
  role             = aws_iam_role.LambdaIamRoleConfigRule.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  description      = "An AWS Config rule that is triggered by configuration changes to EC2 instances. Checks instance tags."
}

resource "aws_lambda_permission" "LambdaPermissionConfigRule" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.LambdaFunctionConfigRule.function_name
  principal     = "config.amazonaws.com"
}

resource "aws_iam_role" "LambdaIamRoleConfigRule" {
  name = "IamRole_Ec2"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : ["lambda.amazonaws.com"]
          },
          "Effect" : "Allow",
        }
      ]
    }
  )
}

# custom/inline policy
resource "aws_iam_role_policy" "ec2role_lambda" {
  name = "ec2-assumerole-lambda"
  role = aws_iam_role.LambdaIamRoleConfigRule.name

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action" : [
            "ec2:TerminateInstances",
            "ec2:StopInstances"
          ],
      "Resource": "arn:aws:ec2:*:516772515805:instance/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "LambdaIamRoleConfigRuleManagedPolicyRoleAttachment0" {
  role       = aws_iam_role.LambdaIamRoleConfigRule.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "LambdaIamRoleConfigRuleManagedPolicyRoleAttachment1" {
  role       = aws_iam_role.LambdaIamRoleConfigRule.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRulesExecutionRole"
}

resource "aws_iam_role_policy_attachment" "LambdaIamRoleConfigRuleManagedPolicyRoleAttachment2" {
  role       = aws_iam_role.LambdaIamRoleConfigRule.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}