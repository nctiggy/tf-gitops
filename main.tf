data "flux_install" "main" {
  target_path = var.target_path
}

data "flux_sync" "main" {
  target_path = var.target_path
  url         = "ssh://git@github.com/${var.github_owner}/${var.github_repository}.git"
  branch      = var.github_branch
}

provider "kubernetes" {
  host  = "https://k8s.bluehairfreak.com:6443"
  cluster_ca_certificate = var.cluster_ca_cert
  client_certificate = var.client_cert
  client_key = var.client_key
}

provider "kubectl" {
  host  = "https://k8s.bluehairfreak.com:6443"
  cluster_ca_certificate = var.cluster_ca_cert
  client_certificate = var.client_cert
  client_key = var.client_key
  load_config_file = false
}

# Kubernetes
resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = var.flux_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
    prevent_destroy = true
  }
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "install" {
  depends_on = [kubernetes_namespace.flux_system]
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body  = each.value
}

resource "kubectl_manifest" "sync" {
  depends_on = [kubectl_manifest.install, kubernetes_namespace.flux_system]
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body  = each.value
}

locals {
  known_hosts = "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
}

resource "tls_private_key" "github_deploy_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "kubernetes_secret" "main" {
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = data.flux_sync.main.secret
    namespace = data.flux_sync.main.namespace
  }

  data = {
    known_hosts    = local.known_hosts
    identity       = tls_private_key.github_deploy_key.private_key_pem
    "identity.pub" = tls_private_key.github_deploy_key.public_key_openssh
  }
}

# To make sure the repository exists and the correct permissions are set.
data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.github_repository}"
}

# For flux to fetch source
resource "github_repository_deploy_key" "flux" {
  title      = var.github_deploy_key_title
  repository = data.github_repository.main.name
  key        = tls_private_key.github_deploy_key.public_key_openssh
  read_only  = true
}
