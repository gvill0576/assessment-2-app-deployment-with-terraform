# outputs.tf
# Output values

output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_stage.prod.invoke_url}"
}

output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.main.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.users_table.name
}

output "lambda_functions" {
  description = "Lambda function names and ARNs"
  value = {
    create_user = {
      name = aws_lambda_function.create_user.function_name
      arn  = aws_lambda_function.create_user.arn
    }
    get_users = {
      name = aws_lambda_function.get_users.function_name
      arn  = aws_lambda_function.get_users.arn
    }
    polly_tts = {
      name = aws_lambda_function.polly_tts.function_name
      arn  = aws_lambda_function.polly_tts.arn
    }
    comprehend_sentiment = {
      name = aws_lambda_function.comprehend_sentiment.function_name
      arn  = aws_lambda_function.comprehend_sentiment.arn
    }
  }
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    region      = var.aws_region
    project     = var.project_name
    environment = var.environment
  }
}
