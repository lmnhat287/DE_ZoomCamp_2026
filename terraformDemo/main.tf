# terraform {
#   required_providers {
#     google = {
#         source = "hashicorp/google"
#         version = "5.6.0"
#     }
#   }
# }

# provider "google" {
#   project = "project-d081e6e1-7099-4c6c-8e9"
#   region  = "us-central1"
# }

# resource "google_storage_bucket" "demo_bucket" {
#     name     = "demo-bucket-1234567890"
#     location = "US"
#     force_destroy = true

#     lifecycle_rule {
#         condition {
#             age = 1
#         }
#         action {
#             type = "AbortIncompleteMultipartUpload"
#         }
#     }
# }

# resource "google_storage_bucket_object" "demo_dataset" {
#     dataset_id   = "demo-data"
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "postgres_image" {
  name         = "postgres:13"
  keep_locally = false
}

resource "docker_container" "db_container" {
  image = docker_image.postgres_image.image_id
  name  = var.container_name
  
  ports {
    internal = 5432
    external = var.external_port
  }

  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}"
  ]
}
