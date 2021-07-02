output "IAM_Role" {
  value = aws_iam_role.lambda_role.id
}

output "DynamoDB_Table_Name" {
  value = aws_dynamodb_table.dynamodb_table.id
}

output "S3_Buckets" {
  value = aws_s3_bucket.s3_buckets.*.id
}

output "SQS_Queue" {
  value = aws_sqs_queue.sqs_queue.id
}

output "Lambda_Function" {
  value = aws_lambda_function.lambda_func.arn
}
