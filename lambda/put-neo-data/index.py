import boto3
import requests
import logging
import sys
import os
import time

# ---- LOGGING CONFIGURATION --- #

logger = logging.getLogger("neo-put-data")
logger.setLevel(logging.INFO)
ch = logging.StreamHandler(stream=sys.stdout)
ch.setLevel(logging.INFO)
formatter = logging.Formatter("%(asctime)s %(levelname)s: %(message)s")
ch.setFormatter(formatter)
logger.addHandler(ch)

# ---- CONNECT TO SDK ---- #

logger.info("Connecting to SDK")
try:
    api_client = boto3.client("apigatewaymanagementapi", region_name="us-east-2")
    ssm_client = boto3.client("ssm", region_name="us-east-2")
    dynamodb_client = boto3.client("dynamodb", region_name="us-east-2")
except:
    logger.error("Could not connect to AWS SDK")

# ---- GET NASA API CONNECTION PARAMETERS ---- #

logger.info("Retriving API key from SSM")
API_KEY = ssm_client.get_parameter(Name="nasa-api-key")
if API_KEY["ResponseMetadata"]["HTTPStatusCode"] == 200:
    logger.info("API key received")
else:
    logger.error("Error retrieving API key")
URL = "https://api.nasa.gov/neo/rest/v1/feed?"


def handler(event, context):
        
# ---- RECEIVE AND PROCESS DATA FROM API ---- #

    params = {
        "api_key": API_KEY["Parameter"]["Value"],
        "start_date": event["date"],
        "end_date": event["date"]
    }

    logger.info(f"Querying API for date: {event['date']}")
    response = requests.get(url=URL, params=params)
    if response.status_code == 200:
        logger.info("HTTP 200 response received, proceeding with database query")
    else:
        logger.error(f"API returned {response.status_code} error for requested date: {event['date']}")
        logger.error(f"API error: {response['errorType']}")
        
    data = response.json()["near_earth_objects"]

    table_data = []
    for object in data[event["date"]]:
        table_data.append({
            "neo_id": object["id"],
            "name": object["name"],
            "estimated_diameter_km_max": round(object["estimated_diameter"]["kilometers"]["estimated_diameter_max"], 2),
            "estimated_diameter_km_min": round(object["estimated_diameter"]["kilometers"]["estimated_diameter_min"], 2),
            "relative_velocity_kms":round(float(object["close_approach_data"][0]["relative_velocity"]["kilometers_per_second"]), 2),
            "miss_distance_lunar": round(float(object["close_approach_data"][0]["miss_distance"]["astronomical"]), 2),
            "miss_distance_astronomical": round(float(object["close_approach_data"][0]["miss_distance"]["astronomical"]), 2)
        })
    
# ---- UPLOAD DATA TO DYNAMODB ---- #
    for date in data.keys():
        put_operations = [{
            "PutRequest": {
                "Item": {
                    "neo_id": {
                        "N": object["neo_id"]
                    },
                    "close_approach_date": {
                        "S": event["date"]
                    },
                    "name": {
                        "S": object["name"]
                    },
                    "estimated_diameter_km_max": {
                        "N": str(object["estimated_diameter_km_max"])
                    },
                    "estimated_diameter_km_min": {
                        "N": str(object["estimated_diameter_km_min"])
                    },
                    "relative_velocity_kms": {
                        "N": str(object["relative_velocity_kms"])
                    },
                    "miss_distance_lunar": {
                        "N": str(object["miss_distance_lunar"])
                    },
                    "miss_distance_astronomical": {
                        "N": str(object["miss_distance_astronomical"])
                    },
                    "uploaded_on": {
                        "N": str(time.time() + (24 * 60 * 60))
                    }
                }
            }
        } for object in table_data]
        put_data = dynamodb_client.batch_write_item(
            RequestItems = {os.environ.get("DYNAMO_DB_TABLE_NAME"): put_operations}
        )
        