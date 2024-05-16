resource "aws_iam_role" "invocation_role" {
  name                                = "api_gateway_auth_invocation_role-snack-shop"
  path                                = "/"
  assume_role_policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "apigateway.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
    ]
}
EOF
}

resource "aws_iam_role_policy" "invocation_policy" {
  name                                = "api_gateway_auth_invocation_policy-snack-shop"
  role                                = aws_iam_role.invocation_role.id
  policy                              = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "lambda:InvokeFunction",
            "Effect": "Allow",
            "Resource": "${aws_lambda_function.authorizer.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role" "lambda" {
  name                                = "lambda_role-snack-shop"
  assume_role_policy                  = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
    ]
}
EOF
}

resource "aws_lambda_function" "authorizer" {
  function_name                       = "api_gateway_authorizer-snack-shop"
  s3_bucket                           = "raw-bucket-snackshop"
  s3_key                              = "lambda.zip"
  role                                = aws_iam_role.lambda.arn
  handler                             = "lambda_authorizer.lambda_handler"
  runtime                             = "python3.8"
  package_type                        = "Zip"
}