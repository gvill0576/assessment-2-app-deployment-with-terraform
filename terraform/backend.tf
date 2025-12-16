# backend.tf
# Remote state storage configuration

terraform {
  backend "s3" {
    bucket         = "gvillalta-assessment-ii-tfstate"
    key            = "assessment-ii/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "assessment-ii-terraform-lock"
    encrypt        = true
  }
}
