import boto3
import os
import json
import logging
import sys
from datetime import datetime as dt
import pandas as pd


# ---- LOGGING CONFIGURATION --- #

logger = logging.getLogger('neo-get-data')
logger.setLevel(logging.INFO)
ch = logging.StreamHandler(stream=sys.stdout)
ch.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s')
ch.setFormatter(formatter)
logger.addHandler(ch)

# ---- CONNECT TO SDK ---- #

logger.info('Connecting to SDK')
try:
    dynamodb_client = boto3.client('dynamodb', region_name='us-east-2')
    lambda_client = boto3.client('lambda', region_name='us-east-2')
except:
    logger.error('Could not connect to AWS SDK')

def handler(event, context):
# ---- LOAD DATA FROM DYNAMODB ---- #
    # Use current date as default if no date argument is passed
    event['date'] = dt.today().strftime('%Y-%m-%d') if event['date'] == '' else event['date']
    
    # Extract date from DynamoDB table
    logger.info(f'Loading data from DynamoDB table for date: {event["date"]}')
    neo_data = get_neo_data(date=event['date'])

    # If not available, trigger update function and read data again    
    if neo_data['Count'] == 0:
        logger.info('Entry not found, updating NEOs table')
        response = lambda_client.invoke(
            FunctionName=os.environ.get('LAMBDA_FUNCTION_PUT'),
            Payload=json.dumps({'date': event['date']})
        )
        neo_data = get_neo_data(date=event['date'])
            
# ---- GET MAX VALUE FOR LARGEST ESTIMATED DIAMETER ---- #
    df = pd.DataFrame(neo_data["Items"])
    df['name'] = [df['name'][i]['S'] for i in range(0, df.shape[0])]
    df['estimated_diameter_feet_max'] = [float(df['estimated_diameter_feet_max'][i]['N']) for i in range(0, df.shape[0])]
    df['relative_velocity_mph'] = [float(df['relative_velocity_mph'][i]['N']) for i in range(0, df.shape[0])]
    largest_neo = df[['name', 'estimated_diameter_feet_max', 'relative_velocity_mph']].iloc[[df['estimated_diameter_feet_max'].idxmax()]]
    neo_data['largest_neo'] = largest_neo.to_dict(orient='split', index=False)
    
    return neo_data

def get_neo_data(date):
    response = dynamodb_client.query(
        TableName=os.environ.get('DYNAMO_DB_TABLE_NAME'),
        IndexName=os.environ.get('GLOBAL_SECONDARY_INDEX'),
        Select='ALL_ATTRIBUTES',
        ExpressionAttributeValues={
            ':date': {
                'S': date,
            }
        },
        KeyConditionExpression='close_approach_date = :date',
    )
    return response
    