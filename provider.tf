terraform {
  required_providers {
    harness = {
      source = "harness/harness"
      # must be at least 0.39.1 for asg support
      version = ">= 0.39.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6"
    }
  }
}
