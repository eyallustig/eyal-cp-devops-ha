module "emails_sqs" {
  source = "../../../../modules/sqs_with_dlq"

  queue_name = local.emails_queue_name
  dlq_name   = local.emails_dlq_name
  tags       = local.tags

  visibility_timeout_seconds    = var.sqs_visibility_timeout_seconds
  receive_wait_time_seconds     = var.sqs_receive_wait_time_seconds
  message_retention_seconds     = var.sqs_message_retention_seconds
  dlq_message_retention_seconds = var.dlq_message_retention_seconds
  max_receive_count             = var.max_receive_count

  # FIFO disabled by default; keep standard queues.
}
