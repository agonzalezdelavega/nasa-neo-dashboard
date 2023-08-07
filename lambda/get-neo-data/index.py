import boto3
import os

client = boto3.client('dynamodb')

def handler(event, context):
    date = event["date"]
    response = client.query(
        TableName=os.environ.get("DYNAMO_DB_TABLE_NAME"),
        IndexName=os.environ.get("GLOBAL_SECONDARY_INDEX"),
        Select="ALL_ATTRIBUTES",
        ExpressionAttributeValues={
        ":date": {
            "S": event["date"],
        }
        },
        KeyConditionExpression="close_approach_date = :date",
    )
    print(response)
    return response