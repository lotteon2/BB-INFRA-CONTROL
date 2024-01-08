resource "aws_sqs_queue" "pickup-review-status-queue" {
  name                      = "pickup-review-status-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600 # 4 days
  visibility_timeout_seconds = 40
  receive_wait_time_seconds = 10
  redrive_policy            = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue0.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue" "dead_letter_queue0" {
  name = "pickup-review-status-dead-letter-queue"
}
resource "aws_sqs_queue_policy" "example_queue_policy0" {
  queue_url = aws_sqs_queue.pickup-review-status-queue.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:*",
      "Resource": "${aws_sqs_queue.pickup-review-status-queue.arn}"
    }
  ]
}
EOF
}