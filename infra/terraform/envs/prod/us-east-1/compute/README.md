# Compute Stack (prod/us-east-1)

This Terraform root module is kept flat (no subfolders) so Terraform loads all .tf files.

## File layout
- `10_data_network.tf` - Default VPC and subnet data sources.
- `20_security_groups.tf` - Worker SG (egress only) and API SG (ingress only from ALB).
- `30_iam.tf` - IAM roles module wiring.
- `40_ecr.tf` - ECR repositories.
- `50_ecs_cluster.tf` - ECS cluster module wiring.
- `60_api_service.tf` - API Fargate service (connected to ALB target group).
- `61_api_alb.tf` - ALB, listener, target group for the API service only.
- `70_worker_service.tf` - Worker Fargate service (no ALB).
- `90_outputs.tf` - Outputs for ALB, services, and task definitions.
