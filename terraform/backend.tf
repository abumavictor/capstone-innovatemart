terraform {
  backend "s3" {
    bucket = "bedrock-assets-alt-soe-025-5344"
    key    = "capstone/terraform.tfstate"
    region = "us-east-1"
  }
}
