terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.27.0"
    }
  }
  backend "gcs" {
    bucket = "$(bucket_name)"
    prefix = "$(backend_value)-statefile"
    credentials = "serviceaccount.json"

  }
}