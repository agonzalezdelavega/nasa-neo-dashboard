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
                "${dynamodb_table}"
            ]
        },
        {
			"Sid": "getKMSKey",
			"Effect": "Allow",
			"Action": "kms:Decrypt",
			"Resource": "${kms_key_arn}"          
        },
        {
			"Sid": "getAPIKey",
			"Effect": "Allow",
			"Action": "secretsmanager:GetSecretValue",
			"Resource": "${api_key_arn}"
		},
        {
            "Sid": "writeLogs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        }
	]
}