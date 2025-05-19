provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name     = "gke-cluster"
  location = var.region
  initial_node_count = 2

  node_config {
    machine_type = "e2-medium"
  }
}

output "kubernetes_cluster_name" {
  value = google_container_cluster.primary.name
}
