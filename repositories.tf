resource "github_repository" "repository" {
  for_each = var.repositories

  name                        = each.key
  description                 = each.value.description != null ? "${each.value.description} (managed by Terraform)" : "managed by Terraform"
  homepage_url                = each.value.homepage_url
  auto_init                   = true
  allow_auto_merge            = (each.value.visibility == "private" ? false : each.value.allow_auto_merge)
  allow_merge_commit          = each.value.allow_merge_commit
  allow_rebase_merge          = each.value.allow_rebase_merge
  allow_squash_merge          = each.value.allow_squash_merge
  allow_update_branch         = each.value.allow_update_branch
  delete_branch_on_merge      = each.value.delete_branch_on_merge
  has_discussions             = each.value.has_discussions
  has_downloads               = each.value.has_downloads
  has_issues                  = each.value.has_issues
  has_projects                = each.value.has_projects
  has_wiki                    = each.value.has_wiki
  is_template                 = each.value.is_template
  topics                      = each.value.topics
  visibility                  = each.value.visibility
  vulnerability_alerts        = each.value.vulnerability_alerts
  web_commit_signoff_required = each.value.web_commit_signoff_required

  security_and_analysis {
    secret_scanning {
      status = each.value.secret_scanning
    }
    secret_scanning_push_protection {
      status = each.value.secret_scanning_push_protection
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch" "branch" {
  for_each = github_repository.repository

  repository = each.value.name
  branch     = "main"
}

resource "github_branch_default" "branch_default" {
  for_each = github_branch.branch

  repository = each.value.repository
  branch     = each.value.branch
}

resource "github_organization_ruleset" "test" {
  enforcement = "disabled"
  name        = "some-name"
  target      = "branch"
  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
    repository_name {
      include = ["til"]
      exclude = []
    }
  }
  rules {
    deletion                = false
    required_linear_history = true
  }
}
