terraform {
  cloud {
    organization = "matijs"

    workspaces {
      name = "github"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.3.0"
    }
  }
}

provider "github" {
  token = var.GITHUB_TOKEN
}
