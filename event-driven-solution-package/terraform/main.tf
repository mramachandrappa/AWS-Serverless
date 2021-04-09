#Terraform Version v0.13.4

provider "aws" {
        region = "us-east-1"
}

locals {
  # Common tags to be assigned to all resources
  Name = "user-subscription-mahesh"
  Environment = "Dev"
}

resource "aws_dynamodb_table" "dynamodb_table" {
  name = var.dynamodb_table_name
  billing_mode = var.dynamodb_billing_mode
  read_capacity = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  hash_key = var.dynamodb_hash_key

  attribute {
    name = var.dynamodb_hash_key
    type = "S"
  }

  tags  = {
    Name = local.Name
    Environment = local.Environment
  }
}

resource "aws_s3_bucket" "s3_buckets" {
  count   = length(var.s3_bucket_names)
  bucket  = var.s3_bucket_names[count.index]
  force_destroy = true

  tags  = {
    Name = local.Name
    Environment = local.Environment
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket  = var.lambda_s3_bucket
  key     = var.lambda_s3_key
  source  = var.lambda_function_package
}

resource "aws_sqs_queue" "sqs_queue" {
  name                        = var.sqs_queue_name
  fifo_queue                  = var.lambda_queue_type_fifo
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  delay_seconds               = var.delay_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds

  tags = {
    Name = local.Name
    Environment = local.Environment
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "LambdaExecutionRole"
  assume_role_policy = file(var.lambda_service_role_policy)
}

data "aws_iam_policy_document" "lambda_execution_policy" {
    statement {
        actions   = [
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        resources = ["*"]
        effect    = "Allow"
    }
    statement {
        actions   = ["s3:PutObject", "s3:GetObject"]
        resources = [for bucket in var.s3_bucket_names:
			"arn:aws:s3:::${bucket}/*"]
        effect    = "Allow"
    }
    statement {
        actions   = [
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem"
            ]
        resources = [aws_dynamodb_table.dynamodb_table.arn]
        effect    = "Allow"
    }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "LambdaExecutionPolicy"
  role =  aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_execution_policy.json
}

resource "aws_lambda_function" "lambda_func" {
  function_name = var.lambda_function_name
  filename	= var.lambda_function_package
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_handler
  source_code_hash = filebase64sha256(var.lambda_function_package)

  runtime = var.lambda_runtime

  tags = {
    Name = local.Name
    Environment = local.Environment
  }
}

resource "aws_lambda_event_source_mapping" "lambda_trigger" {
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  function_name    = aws_lambda_function.lambda_func.arn
  batch_size       = var.lambda_event_source_batchsize
  enabled          = var.lambda_event_source_status
}

