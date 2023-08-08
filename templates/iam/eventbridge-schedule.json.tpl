{
	"Version": "2012-10-17",
	"Statement": [
        {
            "Sid": "invokeLambda",
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "arn:aws:lambda:${region}:${account_id}:function:${function_name}"
        }
	]
}