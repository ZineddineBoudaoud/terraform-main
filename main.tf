provider "aws" {
    profile = "default"
    region = "eu-west-3"
}

resource "aws_dynamodb_table" "back_end_product_table" {
  name           = "Product"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Id"

  attribute {
    name = "Id"
    type = "S"
  }
}

module "sqs_event_service" {
  source = "./modules/sqs_event_service"
}

module "back_end" {
  source = "./modules/ecs_ec2_codepipeline"
  prefix = "esgi-cloud-back-end"
  private_subnet = aws_subnet.private
  public_subnet = aws_subnet.public
  availability_zone = data.aws_availability_zones.available.names
  az_count = var.az_count
  buildspec_path = "${path.module}/conf/back_end/buildspec.yml"
  task_definition_path = "${path.module}/conf/back_end/task_definitions_service.json"
  vpc = aws_vpc.main
  sqs_id = module.sqs_event_service.sqs_id
  sqs_arn = module.sqs_event_service.sqs_arn
  public_subnet_depends_on = [aws_internet_gateway.main]
  code_pipeline_source_conf = {
    OAuthToken = var.GITHUB_ACCESS_TOKEN
    Owner  = "esgi-cloud-project"
    Repo   = "back_end_app"
    Branch = "master"
  }
}

module "front_end" {
  source = "./modules/ecs_ec2_codepipeline"
  prefix = "esgi-cloud-front-end"
  private_subnet = aws_subnet.private
  public_subnet = aws_subnet.public
  availability_zone = data.aws_availability_zones.available.names
  az_count = var.az_count
  buildspec_path = "${path.module}/conf/front_end/buildspec.yml"
  task_definition_path = "${path.module}/conf/front_end/task_definitions_service.json"
  vpc = aws_vpc.main
  sqs_id = module.sqs_event_service.sqs_id
  sqs_arn = module.sqs_event_service.sqs_arn
  public_subnet_depends_on = [aws_internet_gateway.main]
  code_pipeline_source_conf = {
    OAuthToken = var.GITHUB_ACCESS_TOKEN
    Owner  = "esgi-cloud-project"
    Repo   = "front_end_app"
    Branch = "master"
  }
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
