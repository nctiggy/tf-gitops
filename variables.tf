variable "cluster_ca_cert" {
}
variable "client_cert" {
}
variable "client_key" {
}

variable "gcp_project_id" {
  type        = string
  description = "Google Cloud project id to leverage for this deployment"
}

variable "gcp_region" {
  type        = string
  description = "Google Cloud region to deploy into"
}

variable "gcp_zone" {
  type        = string
  description = "Google Cloud zone to deploy into"
}

variable "gke_name" {
  type        = string
  description = "Google Kubernetes Engine deployment name"
}

variable "github_owner" {
  type        = string
  description = "Github org/user the repository lives under"
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "Github PAT with permissions to the flux repos"
}

variable "github_repository" {
  type        = string
  description = "Github repository name"
}

variable "github_branch" {
  type        = string
  description = "Github repository branch"
}

variable "target_path" {
  type        = string
  description = "Relative path to the Git repository root where the sync manifests are committed."
}

variable "flux_namespace" {
  type        = string
  default     = "flux-system"
  description = "the flux namespace"
}

variable "github_deploy_key_title" {
  type        = string
  description = "Name of github deploy key"
}
