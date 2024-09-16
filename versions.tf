terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}
