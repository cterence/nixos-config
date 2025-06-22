plugin "terraform" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  preset  = "all"
  version = "0.12.0"
}

plugin "aws" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  version = "0.40.0"
}

plugin "google" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-google"
  version = "0.33.0"
}
