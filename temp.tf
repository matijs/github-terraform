resource "github_repository" "temp" {
  name                   = "temp"
  allow_auto_merge       = true
  allow_merge_commit     = false
  delete_branch_on_merge = true

  template {
    owner      = "nl-design-system"
    repository = "example"
  }
}

resource "github_repository_ruleset" "temp" {
  name        = "main"
  repository  = github_repository.temp.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  rules {
    required_linear_history = true
    deletion                = true
    non_fast_forward        = true

    pull_request {
      dismiss_stale_reviews_on_push     = true
      required_approving_review_count   = 1
      required_review_thread_resolution = true
    }

    required_status_checks {
      required_check {
        context = "test"
      }
      required_check {
        context = "lint"
      }
      strict_required_status_checks_policy = true
    }
  }
}
