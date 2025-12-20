output "ecr_api_repository_url" {
  description = "ECR repository URL for the api image"
  value       = module.ecr_api.repository_url
}

output "ecr_worker_repository_url" {
  description = "ECR repository URL for the worker image"
  value       = module.ecr_worker.repository_url
}

output "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN (shared)."
  value       = module.iam_roles.execution_role_arn
}

output "api_task_role_arn" {
  description = "Task role ARN for the API service."
  value       = module.iam_roles.api_task_role_arn
}

output "worker_task_role_arn" {
  description = "Task role ARN for the worker service."
  value       = module.iam_roles.worker_task_role_arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.ecs_cluster.cluster_arn
}

output "api_service_arn" {
  value       = module.api_service.service_arn
  description = "API ECS service ARN"
}

output "worker_service_arn" {
  value       = module.worker_service.service_arn
  description = "Worker ECS service ARN"
}

output "api_task_definition_arn" {
  value       = module.api_service.task_definition_arn
  description = "API task definition ARN"
}

output "worker_task_definition_arn" {
  value       = module.worker_service.task_definition_arn
  description = "Worker task definition ARN"
}

output "api_log_group_name" {
  value       = module.api_service.log_group_name
  description = "CloudWatch log group name for API"
}

output "worker_log_group_name" {
  value       = module.worker_service.log_group_name
  description = "CloudWatch log group name for Worker"
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "alb_target_group_arn" {
  description = "Target group ARN attached to the ALB listener"
  value       = module.alb.target_group_arn
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.alb_arn
}
