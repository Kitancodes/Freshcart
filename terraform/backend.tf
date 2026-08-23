terraform {
  backend "s3" {
    bucket         = "freshcart-kitan-688600819893-tfstate"
    key            = "capstone/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "freshcart-terraform-locks"
  }
}