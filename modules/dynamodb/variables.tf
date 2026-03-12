variable "name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "hash_key" {
  description = "The attribute name to use as the primary (hash) key"
  type        = string
}

variable "hash_key_type" {
  description = "The data type of the primary key (S, N, or B)"
  type        = string
  default     = "S"
}

variable "read_capacity" {
  description = "Provisioned read capacity units (ignored if billing_mode is PAY_PER_REQUEST)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Provisioned write capacity units (ignored if billing_mode is PAY_PER_REQUEST)"
  type        = number
  default     = 5
}

variable "billing_mode" {
  description = "Billing mode for the table. Valid values: PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PROVISIONED"
}

variable "deploy_writer_policy" {
  type        = bool
  default     = false
  description = "Whether to deploy the writer IAM policy"
}
