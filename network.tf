resource "aws_vpc" "main" {
  cidr_block = "172.17.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_vpc" "front" {
  cidr_block = "172.18.0.0/16"
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_internet_gateway" "front" {
  vpc_id = aws_vpc.front.id
}

resource "aws_route" "main" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "front" {
  route_table_id         = aws_vpc.front.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.front.id
}