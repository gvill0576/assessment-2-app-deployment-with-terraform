# lambda.tf
# Lambda function resources

# Create User Lambda
resource "aws_lambda_function" "create_user" {
  filename      = "${path.module}/create_user.zip"
  function_name = "${var.project_name}-create-user"
  role          = aws_iam_role.lambda_crud_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = 30
  
  source_code_hash = filebase64sha256("${path.module}/create_user.zip")
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users_table.name
    }
  }
  
  tags = {
    Name = "${var.project_name}-create-user"
  }
}

# Get Users Lambda
resource "aws_lambda_function" "get_users" {
  filename      = "${path.module}/get_users.zip"
  function_name = "${var.project_name}-get-users"
  role          = aws_iam_role.lambda_crud_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = 30
  
  source_code_hash = filebase64sha256("${path.module}/get_users.zip")
  
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.users_table.name
    }
  }
  
  tags = {
    Name = "${var.project_name}-get-users"
  }
}

# Polly TTS Lambda
resource "aws_lambda_function" "polly_tts" {
  filename      = "${path.module}/polly_tts.zip"
  function_name = "${var.project_name}-polly-tts"
  role          = aws_iam_role.lambda_ai_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = 30
  
  source_code_hash = filebase64sha256("${path.module}/polly_tts.zip")
  
  tags = {
    Name = "${var.project_name}-polly-tts"
  }
}

# Comprehend Sentiment Lambda
resource "aws_lambda_function" "comprehend_sentiment" {
  filename      = "${path.module}/comprehend_sentiment.zip"
  function_name = "${var.project_name}-comprehend-sentiment"
  role          = aws_iam_role.lambda_ai_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = 30
  
  source_code_hash = filebase64sha256("${path.module}/comprehend_sentiment.zip")
  
  tags = {
    Name = "${var.project_name}-comprehend-sentiment"
  }
}

# CloudWatch Log Groups (optional but recommended for better organization)
resource "aws_cloudwatch_log_group" "create_user" {
  name              = "/aws/lambda/${aws_lambda_function.create_user.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "get_users" {
  name              = "/aws/lambda/${aws_lambda_function.get_users.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "polly_tts" {
  name              = "/aws/lambda/${aws_lambda_function.polly_tts.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "comprehend_sentiment" {
  name              = "/aws/lambda/${aws_lambda_function.comprehend_sentiment.function_name}"
  retention_in_days = 7
}
