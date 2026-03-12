import json
import boto3
from botocore.exceptions import ClientError


def run_fargate_task(cluster_name, task_definition, subnet_ids, security_group_ids, region_name=None):
    """Run a standalone Fargate task via ECS.

    Parameters:
        cluster_name (str): ECS cluster name or ARN.
        task_definition (str): Task definition family[:revision] or ARN.
        subnet_ids (list): List of subnet IDs (awsvpc network mode).
        security_group_ids (list): List of security group IDs (awsvpc).
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
            taskDefinition=task_definition,
            networkConfiguration={
                "awsvpcConfiguration": {
                    "subnets": subnet_ids,
                    "securityGroups": security_group_ids,
                    "assignPublicIp": "ENABLED",
                }
            },
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
        "subnets": ["subnet-123", "subnet-456"],
        "securityGroups": ["sg-123", "sg-456"],
        "region": "us-east-1"  # optional
    }
    """
    try:
        cluster = event["cluster"]
        task_definition = event["taskDefinition"]
        subnets = event.get("subnets", [])
        security_groups = event.get("securityGroups", [])
        region = event.get("region")

        result = run_fargate_task(cluster, task_definition, subnets, security_groups, region_name=region)
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
