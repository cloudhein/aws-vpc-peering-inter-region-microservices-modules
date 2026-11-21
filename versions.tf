terraform {
  required_version = "~>1.17.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.69.1"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.82.0"
    }
  }
  cloud {
    organization = "nandahc-vcs-driven-team"
    workspaces {
      name = "aws-vpc-peering-inter-region-microservices-modules"
    }
  }
}