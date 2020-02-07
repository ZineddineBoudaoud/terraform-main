provider "aws" {
    profile = "default"
    region = "eu-west-3"
}


module "sqs_event_service" {
  source = "./modules/sqs_event_service"
  
}

module "back_end" {
  source = "./modules/back_end"
  GITHUB_ACCESS_TOKEN = var.GITHUB_ACCESS_TOKEN
  vpc = aws_vpc.main
  sqs_id = module.sqs_event_service.sqs_id
  sqs_arn = module.sqs_event_service.sqs_arn
  public_subnet_depends_on = [aws_internet_gateway.main]
}

module "front_end" {
  source = "./modules/front_end"
  GITHUB_ACCESS_TOKEN = var.GITHUB_ACCESS_TOKEN
  vpc = aws_vpc.front
  public_subnet_depends_on = [aws_internet_gateway.front]
}

module "serverless_app" {
  source = "./modules/serverless_app"
  sqs_id = module.sqs_event_service.sqs_id
  sqs_arn = module.sqs_event_service.sqs_arn
}


output "serverless_app_url" {
  value = module.serverless_app.automate_lambda_base_url
  description = "The url for the serverless application"
}

output "back_end_app_url" {
  value = module.back_end.alb_hostname
  description = "The url for the back end"
}


output "front_end_app_url" {
  value = module.front_end.alb_hostname
  description = "The url for the front end"
}
