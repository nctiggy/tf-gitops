# The block below configures Terraform to use the 'remote' backend with Terraform Cloud.
# For more information, see https://www.terraform.io/docs/backends/types/remote.html
terraform {
  backend "remote" {
    organization = "example-org-8965f3"

    workspaces {
      name = "tf-gitops"
    }
  }

  required_version = ">= 0.13.0"
}
