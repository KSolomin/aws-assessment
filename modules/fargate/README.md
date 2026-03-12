# ECS Fargate helper module

This module provisions a minimal ECS Fargate cluster and service that
runs a one‑off container publishing a message to an SNS topic. It is
intended for assessment / demonstration purposes and keeps networking
simple by using the default VPC/public subnet so no NAT gateway is needed.

## Resources created

* ECS cluster
* CloudWatch log group (`/ecs/<cluster_name>`)
* IAM execution role (with the managed ECS task execution policy)
* IAM task role with inline policy allowing `sns:Publish` to the topic
* Security group allowing all outbound traffic
* ECS task definition using `amazon/aws-cli` image
* ECS service (FARGATE) with desired count = 1

## Usage example

```hcl
module "sns_publisher" {
  source        = "../modules/fargate"
  cluster_name  = "demo"
  sns_topic_arn = aws_sns_topic.my_topic.arn
  message       = "hello from terraform"
  # cpu/memory default to 256/512
}
```

This will spin up the service in the default VPC's first subnet and
immediately execute the CLI command defined in the task.

> 📝 **Note:** the module assumes the default VPC exists and uses the
first subnet returned by `aws_subnet_ids`. It also assigns a public IP
so the task can reach SNS without private networking/NAT.
