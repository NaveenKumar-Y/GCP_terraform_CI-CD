terraform {
    required_providers {
      google = {
        source = "hashicorp/google"
        version = "4.27.0"
      }
    }
  backend "gcs" {
        bucket = var.bucket_name
        prefix = "#{backend-value}#-statefile"
        credentials = "serviceaccount.json"
  }
}