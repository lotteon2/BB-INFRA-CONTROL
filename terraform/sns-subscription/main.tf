provider "aws" {
  profile = "prod"
  region  = "ap-northeast-1"
}

# sns
module "new-order-event" {
  source = "./new-order-event"
}
module "review-register-event" {
  source = "./review-register-event"
}

# sqs
module "review-register-queue" {
  source = "./review-register-queue"
}
module "sale-count-update-queue" {
  source = "./sale-count-update"
}
module "new-order-queue" {
  source = "./new-order-queue"
}


# sns subscribe
resource "aws_sns_topic_subscription" "review-register-subscribe" {
  endpoint  = module.review-register-queue.product-review-data-update-queue-arn
  protocol  = "sqs"
  topic_arn = module.review-register-event.review_register_event-arn
}

resource "aws_sns_topic_subscription" "new-order-subscribe" {
  endpoint  = module.sale-count-update-queue.sale-count-queue-arn
  protocol  = "sqs"
  topic_arn = module.new-order-event.new_order_event-arn
}
resource "aws_sns_topic_subscription" "new-order-event-subscribe" {
  endpoint  = module.new-order-queue.new-order-queue-arn
  protocol  = "sqs"
  topic_arn = module.new-order-event.new_order_event-arn
}