resource "aws_sqs_queue" "dlq" {
  name                        = var.dlq_name
  fifo_queue                  = var.fifo_queue
  message_retention_seconds   = var.dlq_message_retention_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  sqs_managed_sse_enabled     = var.sqs_managed_sse_enabled

  tags = var.tags
}

resource "aws_sqs_queue" "main" {
  name                        = var.queue_name
  fifo_queue                  = var.fifo_queue
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  message_retention_seconds   = var.message_retention_seconds
  sqs_managed_sse_enabled     = var.sqs_managed_sse_enabled

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = var.tags
}
