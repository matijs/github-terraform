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
    secret_scanning                 = optional(string, "enabled")
    secret_scanning_push_protection = optional(string, "enabled")
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
      # `main` already exists so creation does not make sense
      creation                      = optional(bool, false)
      deletion                      = optional(bool, true)
      non_fast_forward              = optional(bool, true)
      required_linear_history       = optional(bool, true)
      required_signatures           = optional(bool, true)
      update                        = optional(bool, false)
      update_allows_fetch_and_merge = optional(bool, false)

      pull_request = optional(object({
        dismiss_stale_reviews_on_push     = optional(bool, true)
        require_code_owner_review         = optional(bool, true)
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
          context        = string
          integration_id = optional(number, 0)
        }))
        strict_required_status_checks_policy = optional(bool, true)
      }))
    })
  }))
}
