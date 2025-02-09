variable "GITHUB_TOKEN" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "repositories" {
  type = map(object({
    description                     = optional(string)
    homepage_url                    = optional(string)
    allow_auto_merge                = optional(bool, true)
    allow_merge_commit              = optional(bool, false)
    allow_rebase_merge              = optional(bool, true)
    allow_squash_merge              = optional(bool, true)
    allow_update_branch             = optional(bool, true)
    delete_branch_on_merge          = optional(bool, true)
    has_discussions                 = optional(bool, false)
    has_downloads                   = optional(bool, false)
    has_issues                      = optional(bool, true)
    has_projects                    = optional(bool, false)
    has_wiki                        = optional(bool, false)
    is_template                     = optional(bool, false)

    security_and_analysis = optional(object({
      secret_scanning = object({
        status = optional(string, "enabled")
      })
      secret_scanning_push_protection = object({
        status = optional(string, "enabled")
      })
    }))

    topics                          = optional(list(string), [])
    visibility                      = optional(string, "public")
    vulnerability_alerts            = optional(bool, true)
    web_commit_signoff_required     = optional(bool, false)
  }))
}

variable "rulesets" {
  type = map(object({
    enforcement = optional(string, "active")
    name        = optional(string, "default-branch-protection")

    rules = object({
      deletion                      = optional(bool, true)
      non_fast_forward              = optional(bool, true)
      required_linear_history       = optional(bool, true)
      required_signatures           = optional(bool, false)
      update_allows_fetch_and_merge = optional(bool, false)

      pull_request = optional(object({
        dismiss_stale_reviews_on_push     = optional(bool, false)
        require_code_owner_review         = optional(bool, false)
        require_last_push_approval        = optional(bool, false)
        required_approving_review_count   = optional(number, 0)
        required_review_thread_resolution = optional(bool, false)
        }), {
        # always require at least a pull request
        required_approving_review_count = 0
      })

      required_status_checks = optional(object({
        do_not_enforce_on_create = optional(bool, false)
        required_check = list(object({
          context = string
        }))
        strict_required_status_checks_policy = optional(bool, false)
      }))
    })
  }))
}
