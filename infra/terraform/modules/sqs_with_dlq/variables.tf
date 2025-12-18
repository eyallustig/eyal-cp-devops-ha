variable "queue_name" {
  description = "Name of the main SQS queue"
  type        = string
}

variable "dlq_name" {
  description = "Name of the dead-letter SQS queue"
  type        = string
}

variable "tags" {
  description = "Tags to apply to both queues"
  type        = map(string)
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the main queue in seconds"
  type        = number
  default     = 60
}

variable "receive_wait_time_seconds" {
  description = "Long polling wait time for both queues (0-20 seconds)"
  type        = number
  default     = 20

  validation {
    condition     = var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20
    error_message = "receive_wait_time_seconds must be between 0 and 20 seconds."
  }
}

variable "message_retention_seconds" {
  description = "Message retention for the main queue in seconds"
  type        = number
  default     = 345600 # 4 days
}

variable "dlq_message_retention_seconds" {
  description = "Message retention for the DLQ in seconds"
  type        = number
  default     = 1209600 # 14 days
}

variable "max_receive_count" {
  description = "Number of receives before moving a message to the DLQ"
  type        = number
  default     = 5

  validation {
    condition     = var.max_receive_count >= 1
    error_message = "max_receive_count must be at least 1."
  }
}

variable "sqs_managed_sse_enabled" {
  description = "Enable SQS managed server-side encryption"
  type        = bool
  default     = true
}

variable "fifo_queue" {
  description = "Whether to create FIFO queues (names must end with .fifo if true)"
  type        = bool
  default     = false

  validation {
    condition = var.fifo_queue == false ? true : (
      endswith(var.queue_name, ".fifo") && endswith(var.dlq_name, ".fifo")
    )
    error_message = "When fifo_queue is true, both queue_name and dlq_name must end with .fifo."
  }
}
