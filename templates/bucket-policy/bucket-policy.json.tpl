{
    "Version": "2012-10-17",
    "Id": "allowGetObject",
    "Statement": [
        {
            "Sid": "Stmt1497053406813",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${bucket_name}/*"
        }
    ]
}