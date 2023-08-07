{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "getObjectsFromS3",
			"Effect": "Allow",
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::${bucket_name}/*"
		},
        {
            "Sid": "dynamoDBActions",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:Query"
            ],
            "Resource": [
                "arn:aws:dynamodb:${region}:${account_id}:table/${dynamodb_table}"
            ]
        },
        {
			"Sid": "getAPIKey",
			"Effect": "Allow",
			"Action": "ssm:GetParameter",
			"Resource": "arn:aws:ssm:${region}:${account_id}:parameter/${api_key_parameter_name}"
		},
        {
            "Sid": "writeLogs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${region}:${account_id}:log_group:${log_group}",
                "arn:aws:logs:${region}:${account_id}:log_group:${log_group}:log-stream:*"
            ]
        }
	]
}