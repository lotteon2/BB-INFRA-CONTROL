resource "aws_sns_topic" "review_register_event" {
  name         = "review-register-event"
  display_name = "review register event"
}
output "review_register_event-arn" {
  value = aws_sns_topic.review_register_event.arn
}
