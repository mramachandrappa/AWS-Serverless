s3_bucket_names 		= ["sst-user-events", "sst-subscription-events", "sst-lesson-events", "sst-event-lambda-function"]
lambda_service_role_policy 	= "../policies/LambdaServicePolicy.json"
lambda_execution_policy 	= "../policies/LambdaExecutionPolicy.json"
dynamodb_table_name 		= "user-subscriptions"
dynamodb_billing_mode		= "PROVISIONED"
dynamodb_read_capacity		= 5
dynamodb_write_capacity		= 5
dynamodb_hash_key		= "UserUUID"
lambda_function_package		= "../function.zip"
lambda_s3_bucket		= "event-lambda-function"
lambda_s3_key			= "function.zip"
sqs_queue_name			= "events-queue.fifo"
lambda_queue_type_fifo		= true
visibility_timeout_seconds 	= 30
message_retention_seconds   	= 345600
delay_seconds		    	= 30
receive_wait_time_seconds   	= 10
lambda_function_name	    	= "user-events-processing"
lambda_handler		    	= "lambda_function.lambda_handler"
lambda_runtime		    	= "python3.8"
lambda_event_source_batchsize 	= 10
lambda_event_source_status    	= true
