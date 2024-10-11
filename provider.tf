terraform {
  required_version = "~> 1.9.0"

  cloud {
    organization = "matijs"

    workspaces {
      name = "github"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.3.1"
    }
  }
}

provider "github" {
  token = var.GITHUB_TOKEN
}
