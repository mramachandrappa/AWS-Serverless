variable "s3_bucket_names"{
  type = list
  description = "S3 buckets to store lambda function package and events"
}

variable "lambda_service_role_policy"{
  type = string
  default = "../policies/LambdaServicePolicy.json"
  description = "Lambda service role policy"
}

variable "lambda_execution_policy"{
  type = string
  default = "../policies/LambdaExecutionPolicy.json"
  description = "Policy to allow lambda necessary permissions to access SQS|DynamoDB|S3"
}

variable "dynamodb_table_name"{
  type = string
  default = "user-subscriptions"
  description = "Name for DynamoDB table"
}

variable "dynamodb_billing_mode" {
  type = string
  default = "PROVISIONED"
  description = "To control read and write throughput charges and to manage capacity"
}
variable "dynamodb_read_capacity"{
  type = number
  default = 5
  description = "The number of read units for the table"
}

variable "dynamodb_write_capacity"{
  type = number
  default = 5
  description = "The number of write units for the table"
}

variable "dynamodb_hash_key"{
  type = string
  default = "UserUUID"
  description = "The attribute to use as the hash (partition) key. "
}

variable "lambda_function_package" {
  type = string
  default = "../function.zip"
  description = "local path to the zip package containing lambda code and dependencies"
}

variable "lambda_s3_bucket"{
  type = string
  default = "sst-event-lambda-function"
  description = "S3 bucket where lambda function is uploaded."
}

variable "sqs_queue_name" {
  type = string
  default = "event-events-queue.fifo"
  description = "SQS Queue name. Should be .fifo if queue type is FIFO"
}

variable "lambda_queue_type_fifo" {
  type = bool
  default = true
  description = "Boolean designating a FIFO queue. If not set, it defaults to false making it standard."
}
variable "visibility_timeout_seconds" {
  type = number
  default = 30
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours)"
}

variable "message_retention_seconds" {
  type = number
  default = 345600
  description = "The number of seconds Amazon SQS retains a message. Integer represents seconds from 1 minute to 14 days"
}

variable "delay_seconds" {
  type = number
  default = 30
  description = "The time in seconds that the delivery of all messages in the queue will be delayed"
}

variable "receive_wait_time_seconds" {
  type = number
  default = 10
  description = "The maximum amount of time that polling will wait for messages to become available to receive"
}

variable "lambda_function_name" {
  type = string
  default = "user-events-processing"
  description = "Lambda function name"
}

variable "lambda_s3_key"{
  type = string
  default = "function.zip"
  description = "s3 key"
}

variable "lambda_handler" {
  type = string
  default = "lambda_function.lambda_handler"
  description = "fileName.functionName"
}

variable "lambda_runtime" {
  type = string
  default = "python3.8"
  description = "Runtime engine for lambda function"
}

variable "lambda_event_source_batchsize" {
  type = number
  default = 10
  description = "The largest number of records that Lambda will retrieve from event source at the time of invocation."
}

variable "lambda_event_source_status" {
  type = bool
  default = true
  description = "Lambda event source status Enable|Disable"
}
