{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::${bucket_name}/*"
		},
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:Query"
            ],
            "Resource": [
                "arn:aws:dynamodb:us-east-2:*:table/Chat-Conversations",
                "arn:aws:dynamodb:us-east-2:*:table/Chat-Messages",
                "arn:aws:dynamodb:us-east-2:*:table/Chat-Conversations/index/Username-ConversationId-index"
            ]
        }
	]
}