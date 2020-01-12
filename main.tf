module "sqs_event_service" {
  source = "./modules/sqs_event_service"
  
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

