resource "aws_sqs_queue" "product-resale-notification-queue" {
  name                       = "product-resale-notification-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600 # 4 days
  visibility_timeout_seconds = 40
  receive_wait_time_seconds  = 10
  redrive_policy             = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue10.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue" "dead_letter_queue10" {
  name = "product-resale-notification-dead-letter-queue"
}
resource "aws_sqs_queue_policy" "example_queue_policy10" {
  queue_url = aws_sqs_queue.product-resale-notification-queue.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.product-resale-notification-queue.arn}"
    }
  ]
}
EOF
}