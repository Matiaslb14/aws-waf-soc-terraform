resource "aws_sns_topic" "waf_alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.waf_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_allow_sns" {
  role = aws_iam_role.lambda_role.id
  name = "${var.project_name}-lambda-sns"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["sns:Publish"],
      Resource = [aws_sns_topic.waf_alerts.arn]
    }]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "waf_parser" {
  function_name = "${var.project_name}-waf-parser"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  filename      = data.archive_file.lambda_zip.output_path
  timeout       = 30
  environment { variables = { SNS_TOPIC_ARN = aws_sns_topic.waf_alerts.arn } }
}
