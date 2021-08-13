resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "google_container_cluster" "test" {
  name             = "test"
  location         = "us-west1"
  network          = google_compute_network.vpc_network.self_link
  enable_autopilot = true
}

data "google_client_config" "default" {
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${google_container_cluster.test.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.test.master_auth[0].cluster_ca_certificate,
  )
}

data "kubernetes_all_namespaces" "allns" {}

output "all-ns" {
  value = data.kubernetes_all_namespaces.allns.namespaces
}

output "endpoint" {
  value = google_container_cluster.test.endpoint
}
