terraform {
  required_version = ">= 0.13"
}

locals {
  src-dir    = "../../lambda/${var.app_name}"
  build-dir  = "${local.src-dir}/build"
  build-file = "${local.build-dir}/${var.app_name}.zip"
}

resource "aws_s3_bucket" "terraform_deployment_bucket" {
  bucket = "${var.app_name}-deployments"
  # Enable versioning so we can see the full revision history of our state files
  versioning {
    enabled = false
  }

  force_destroy = true

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  provisioner "local-exec" {
    command = "zip ${local.build-file} ${local.src-dir}/main.js && aws s3 cp ${local.build-file} s3://${var.app_name}-deployments/v1.0.0/${var.app_name}.zip"
  }
}