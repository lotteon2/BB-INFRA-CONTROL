resource "aws_sqs_queue" "product-resale-notification-check-queue" {
  name                       = "product-resale-notification-check-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600 # 4 days
  visibility_timeout_seconds = 40
  receive_wait_time_seconds  = 10
  redrive_policy             = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue17.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue" "dead_letter_queue17" {
  name = "product-resale-notification-check-dead-letter-queue"
}
resource "aws_sqs_queue_policy" "example_queue_policy17" {
  queue_url = aws_sqs_queue.product-resale-notification-check-queue.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.product-resale-notification-check-queue.arn}"
    }
  ]
}
EOF
}