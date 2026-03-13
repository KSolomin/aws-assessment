import json
import os
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource("dynamodb")
sns = boto3.client("sns", region_name='us-east-1')

TABLE_NAME = os.environ["TABLE_NAME"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
EMAIL = os.environ["EMAIL"]
REPO = os.environ["REPO"]

def lambda_handler(event, context):
    region = os.environ.get("AWS_REGION", "unknown")
    table = dynamodb.Table(TABLE_NAME)

    # Write record to DynamoDB
    record = {
        "id": str(uuid.uuid4()),
        "timestamp": datetime.utcnow().isoformat(),
        "region": region
    }

    table.put_item(Item=record)

    # Prepare SNS payload
    payload = {
        "email": EMAIL,
        "source": "Lambda",
        "region": region,
        "repo": REPO
    }

    # Publish verification message
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=json.dumps(payload)
    )

    # API Gateway response
    return {
        "statusCode": 200,
        "body": json.dumps({
            "region": region
        })
    }
