provider "aws" {
  profile = "prod"
  region  = "ap-northeast-1"
}

resource "aws_sns_topic" "card-register-event" {
  name         = "card-register-event"
  display_name = "card-register-event"
}
output "card-register-event-arn" {
  value = aws_sns_topic.card-register-event.arn
}

resource "aws_sns_topic" "product-resale-notification" {
  name         = "product-resale-notification"
  display_name = "product-resale-notification"
}