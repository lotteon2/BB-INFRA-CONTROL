resource "aws_sns_topic" "new_order_event" {
  name         = "new-order-event"
  display_name = "new order event"
}
output "new_order_event-arn" {
  value = aws_sns_topic.new_order_event.arn
}
