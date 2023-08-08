{
	"Version": "2012-10-17",
	"Statement": [
        {
            "Sid": "dynamoDBActions",
            "Effect": "Allow",
            "Action": [
                "dynamodb:Query"
            ],
            "Resource": [
                "arn:aws:dynamodb:${region}:${account_id}:table/${dynamodb_table}/index/*"
            ]
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