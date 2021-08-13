variable "gcp_credentials" {
  type        = string
  sensitive   = true
  description = "Google Cloud service account credentials"
}

provider "google" {
  project     = "tf-gitops-322602"
  credentials = var.gcp_credentials
  region      = "us-west1"
  zone        = "us-west1-a"
}
