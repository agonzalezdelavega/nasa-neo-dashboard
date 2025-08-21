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
                "${dynamodb_table}/index/*"
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
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Sid": "invokeLambda",
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "arn:aws:lambda:${region}:${account_id}:function:${function_name}"
        }
	]
}