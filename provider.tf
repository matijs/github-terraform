terraform {
  required_version = "~> 1.11.0"

  cloud {
    organization = "matijs"

    workspaces {
      name = "github"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "github" {
  token = var.GITHUB_TOKEN
}
