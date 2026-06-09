terraform {
  backend "s3" {
    bucket         = "securebank-terraform-state-028417007027"
    key            = "securebank/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "securebank-terraform-locks"
    encrypt        = true
  }
}
