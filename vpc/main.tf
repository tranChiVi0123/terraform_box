provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "./vpc-module"

  vpc_cidr_block    = "10.0.0.0/16"
  private_subnet    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zone = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}
