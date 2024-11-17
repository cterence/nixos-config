plugin "terraform" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  preset  = "all"
  version = "0.10.0"
}

plugin "aws" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  version = "0.35.0"
}

plugin "google" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-google"
  version = "0.30.0"
}
