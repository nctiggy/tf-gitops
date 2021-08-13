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

output "endpoint" {
  value = google_container_cluster.test.endpoint
}
