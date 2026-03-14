# AWS Assessment

This repository contains an AWS infrastructure setup for a project assessment using Terraform and Terragrunt - or, more precisely, a draft to show how the real repo structure could look like.

## Project Structure

- `environments/`: Environment-specific Terragrunt configurations
  - `sandbox/`: Sandbox environment with regions `eu-west-1` and `us-east-1`
    - Components: API Gateway, Dispatcher, DynamoDB, Fargate, Greeter
- `modules/`: Reusable Terraform modules for AWS services
  - API Gateway, Cognito, DynamoDB, Fargate, Lambda functions (Dispatcher, Greeter)
- `test/`: End-to-end tests with Python

## Prerequisites

- Terraform
- Terragrunt
- AWS CLI configured with appropriate credentials
- Python3

## Deployment

1. Navigate to the desired environment directory (e.g., `environments/sandbox/eu-west-1/`)
2. Run `terragrunt run --all init` to initialize
3. Run `terragrunt run --al plan` to preview changes
4. Run `terragrunt run --al apply` to deploy`

## Testing

Run end-to-end tests from the `test/` directory.