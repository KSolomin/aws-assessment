import json
import boto3
import os
from botocore.exceptions import ClientError


def run_fargate_task(cluster_name, task_definition, region_name=None):
    """Run a standalone Fargate task via ECS.

    Parameters:
        cluster_name (str): ECS cluster name or ARN.
        task_definition (str): Task definition family[:revision] or ARN.
        region_name (str, optional): Region to use.

    Returns:
        dict: ECS run_task response.
    """
    client_kwargs = {}
    if region_name:
        client_kwargs["region_name"] = region_name

    ecs = boto3.client("ecs", **client_kwargs)

    try:
        response = ecs.run_task(
            cluster=cluster_name,
            launchType="FARGATE",
            taskDefinition=task_definition
        )
        return response
    except ClientError as e:
        print(f"error running task: {e}")
        raise


def lambda_handler(event, context):
    """Lambda entry point expecting keys in the event:
    {
        "cluster": "my-cluster",
        "taskDefinition": "my-task-def",
        "region": "us-east-1"  # optional
    }
    """
    try:
        cluster = os.environ.get("CLUSTER_NAME")
        task_definition = os.environ.get("TASK_DEFINITION")
        region = os.environ.get("AWS_REGION")

        result = run_fargate_task(cluster, task_definition, region_name=region)
        return {
            "statusCode": 200,
            "body": json.dumps(result, default=str)
        }
    except KeyError as e:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": f"missing parameter: {e}"})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
