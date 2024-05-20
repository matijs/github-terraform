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
    visibility                      = optional(string, "public")
    vulnerability_alerts            = optional(bool, true)
    web_commit_signoff_required     = optional(bool, false)
  }))
}

variable "branch_protections" {
  type = list(object({
    name                            = string
    enforce_admins                  = optional(bool, true)
    required_linear_history         = optional(bool, true)
    strict                          = optional(bool, true)
    contexts                        = optional(list(string), [])
    required_approving_review_count = optional(number, 0)
    require_last_push_approval      = optional(bool, false)
  }))
}

resource "github_repository" "all" {
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

resource "github_branch_protection" "all" {
  for_each = { for p in var.branch_protections : p.name => p }

  repository_id           = github_repository.all[each.value.name].node_id
  pattern                 = github_repository.all[each.value.name].default_branch
  enforce_admins          = each.value.enforce_admins
  required_linear_history = each.value.required_linear_history
  required_status_checks {
    strict   = each.value.strict
    contexts = each.value.contexts
  }
  required_pull_request_reviews {
    required_approving_review_count = each.value.required_approving_review_count
    require_last_push_approval      = each.value.require_last_push_approval
  }
}

resource "github_branch" "main" {
  for_each = github_repository.all

  repository = each.value.name
  branch     = "main"
}

resource "github_branch_default" "main" {
  for_each = github_branch.main

  repository = each.value.repository
  branch     = each.value.branch
}

