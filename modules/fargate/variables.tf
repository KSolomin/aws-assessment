variable public_subnet_id {
  type        = string
  default     = ""
  description = "description"
}

variable "vpc_id" {
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster and related resources"
  type        = string
  default     = "fargate-cluster"
}

variable "sns_topic_arn" {
  description = "SNS topic ARN that the task will publish messages to"
  type        = string
}

variable "message" {
  description = "Message to publish to SNS"
  type        = map(string)
  default     = {
    email = ""
    source = "Lambda"
    region = ""
    repo = ""
  }
}

variable "cpu" {
  description = "CPU units for the Fargate task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory (MiB) for the Fargate task"
  type        = string
  default     = "512"
}

