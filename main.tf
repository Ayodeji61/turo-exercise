terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# Configure the Kubernetes provider with a specific kubeconfig file and context
provider "kubernetes" {
  config_path    = "kube/config"
  config_context = "turo-interview"
}

# External data source to fetch the application version from a local file
data "external" "app_version" {
  program = ["bash", "-c", "echo {\\\"version\\\":\\\"$(cat VERSION)\\\"}"]
}

#data "external" "app_version" {
#  program = ["powershell", "-Command", "$version = Get-Content -Path VERSION -Raw; [PSCustomObject]@{version = $version} | ConvertTo-Json"]
#}

# Define a variable for the Kubernetes namespace with a default value
variable "namespace" {
  description = "namespace"
  type        = string
  default     = "candidate-b"
}

# Create a Kubernetes ConfigMap for environment variables, using the app version
resource "kubernetes_config_map" "app_env" {
  metadata {
    name      = "ayodejia-env"
    namespace = var.namespace
  }

  data = {
    ".env" = <<-EOT
    WELCOME_MESSAGE = "HAPPY CODING CHALLENGE - TURO - ${data.external.app_version.result.version}"
    EOT
  }
}

# Create a Kubernetes ConfigMap for application configuration
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "ayodejia-config"
    namespace = var.namespace
  }

  data = {
    "config.html" = <<-EOT
      <!DOCTYPE html>
      <html lang="en">

      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Config file</title>
          <style>
              body {
                  background-color: lightgrey;
                  font-family: Arial, sans-serif;
              }

              .container {
                  text-align: center;
                  padding: 50px;
              }

              h1 {
                  color: maroon;
              }

              p {
                  color: darkslateblue;
              }

              a {
                  color: navy;
                  text-decoration: none;
                  font-weight: bold;
              }
          </style>
      </head>

      <body>
          <div class="container">
              <h1>Config Page</h1>
              <a href="index.html">Back to Home</a>
          </div>
      </body>

      </html>
      EOT
  }
}

# Define a Kubernetes deployment for the application
resource "kubernetes_deployment" "app" {
  depends_on = [
    kubernetes_config_map.app_config,
    kubernetes_config_map.app_env
  ]
  metadata {
    name      = "ayodejia-app"
    namespace = var.namespace
    labels = {
      app = "ayodejia-app"
    }
  }
  spec {
    replicas               = 1
    revision_history_limit = 2
    selector {
      match_labels = {
        app = "ayodejia-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "ayodejia-app"
        }
        annotations = {
          "config-version" = sha256(jsonencode(kubernetes_config_map.app_config.data))
          "env-version"    = sha256(jsonencode(kubernetes_config_map.app_env.data))
        }
      }

      # Container specification
      spec {
        container {
          image             = "ayodejia/turo:${data.external.app_version.result.version}"
          name              = "ayodejia-app-container"
          image_pull_policy = "Always"

          port {
            container_port = 80
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "200Mi"
            }
          }
          # Mounting volumes for config and environment files
          volume_mount {
            name       = "config-volume"
            mount_path = "/app/public/config.html"
            sub_path   = "config.html"
          }
          volume_mount {
            name       = "env-volume"
            mount_path = "/app/.env"
            sub_path   = ".env"
          }
        }
        # Define volumes sourced from ConfigMaps
        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.app_config.metadata[0].name
          }
        }
        volume {
          name = "env-volume"
          config_map {
            name = kubernetes_config_map.app_env.metadata[0].name
          }
        }
      }
    }
  }
}

# Create a Kubernetes Service for the application
resource "kubernetes_service_v1" "service" {
  metadata {
    name      = "ayodejia-svc"
    namespace = var.namespace
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.metadata[0].labels.app
    }
    port {
      name        = "https"
      port        = 443
      protocol    = "TCP"
      target_port = 80
    }
    type = "ClusterIP"
  }
}

# Define a Kubernetes Ingress resource for external access to the application
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "ayodejia-ingress"
    namespace = var.namespace
    annotations = {
      "external-dns.alpha.kubernetes.io/hostname"  = "ayodeji.test-subaccount-1-v02.test-subaccount-1.rr.mu"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "kubernetes.io/ingress.class" : "nginx"
    }
  }

  spec {
    rule {
      host = "ayodeji.test-subaccount-1-v02.test-subaccount-1.rr.mu"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.service.metadata[0].name
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}
