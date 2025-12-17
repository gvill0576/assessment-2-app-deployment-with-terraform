# iam.tf
# IAM roles and policies for Lambda functions

# Trust policy document - allows Lambda to assume roles
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

# IAM role for CRUD Lambda functions
resource "aws_iam_role" "lambda_crud_role" {
  name               = "${var.project_name}-lambda-crud-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  
  tags = {
    Name = "${var.project_name}-lambda-crud-role"
  }
}

# Policy for DynamoDB access
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "dynamodb-access"
  role = aws_iam_role.lambda_crud_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.users_table.arn
      }
    ]
  })
}

# Attach CloudWatch Logs policy for Lambda logging
resource "aws_iam_role_policy_attachment" "lambda_crud_logs" {
  role       = aws_iam_role.lambda_crud_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM role for AI service Lambda functions
resource "aws_iam_role" "lambda_ai_role" {
  name               = "${var.project_name}-lambda-ai-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  
  tags = {
    Name = "${var.project_name}-lambda-ai-role"
  }
}

# Policy for Polly and Comprehend access
resource "aws_iam_role_policy" "lambda_ai_policy" {
  name = "ai-services-access"
  role = aws_iam_role.lambda_ai_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "polly:SynthesizeSpeech",
          "polly:DescribeVoices",
          "comprehend:DetectSentiment",
          "comprehend:DetectEntities"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach CloudWatch Logs policy
resource "aws_iam_role_policy_attachment" "lambda_ai_logs" {
  role       = aws_iam_role.lambda_ai_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
