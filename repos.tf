variable "repos" {
  type = list(object({
    name                            = string
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

variable "branch_protections" {
  type = list(object({
    name                            = string
    enforce_admins                  = optional(bool, true)
    allows_deletions                = optional(bool, false)
    allows_force_pushes             = optional(bool, false)
    required_linear_history         = optional(bool, true)
    strict                          = optional(bool, true)
    contexts                        = optional(list(string), [])
    required_approving_review_count = optional(number, 0)
    require_last_push_approval      = optional(bool, false)
  }))
}

variable "branch_rulesets" {
  type = list(object({
    name                            = optional(string, "main-branch-protection")
    repository                      = string
    enforcement                     = optional(string, "disabled")
    required_linear_history         = optional(bool, true)
    required_approving_review_count = optional(number, 0)
    require_last_push_approval      = optional(bool, false)
  }))
}

resource "github_repository" "r" {
  for_each = { for repo in var.repos : repo.name => repo }

  name                        = each.value.name
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

resource "github_repository_ruleset" "branch_protection" {
  for_each = { for r in var.branch_rulesets : r.repository => r }

  name        = each.value.name
  repository  = each.value.repository
  enforcement = each.value.enforcement
  target      = "branch"

  conditions {
    ref_name {
      include = ["refs/heads/main"]
      exclude = []
    }
  }

  rules {
    pull_request {
      required_approving_review_count = each.value.required_approving_review_count
      require_last_push_approval      = each.value.require_last_push_approval
    }
    required_linear_history = each.value.required_linear_history
  }
}

resource "github_branch_protection" "b" {
  for_each = { for p in var.branch_protections : p.name => p }

  repository_id           = github_repository.r[each.value.name].node_id
  pattern                 = github_repository.r[each.value.name].default_branch
  enforce_admins          = each.value.enforce_admins
  allows_deletions        = each.value.allows_deletions
  allows_force_pushes     = each.value.allows_force_pushes
  required_linear_history = each.value.required_linear_history

  required_status_checks {
    # this is only honoured if there is a GitHub status check (a context)
    strict   = each.value.strict
    contexts = each.value.contexts
  }

  required_pull_request_reviews {
    required_approving_review_count = each.value.required_approving_review_count
    require_last_push_approval      = each.value.require_last_push_approval
  }
}

resource "github_branch" "main" {
  for_each = github_repository.r

  repository = each.value.name
  branch     = "main"
}

resource "github_branch_default" "main" {
  for_each = github_branch.main

  repository = each.value.repository
  branch     = each.value.branch
}
