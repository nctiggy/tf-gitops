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

provider "helm" {
  kubernetes {
    host  = "https://${google_container_cluster.test.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      google_container_cluster.test.master_auth[0].cluster_ca_certificate,
    )
  }
}

resource "helm_release" "contour" {
  name       = "contour"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "contour"
  version    = "5.1.0"

  set {
    name  = "envoy.useHostPort"
    value = "false"
  }
}

output "endpoint" {
  value = google_container_cluster.test.endpoint
}
