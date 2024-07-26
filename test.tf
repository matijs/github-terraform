variable "foobar" {
  type = string
}

resource "github_repository" "test" {
  name = var.foobar
}
