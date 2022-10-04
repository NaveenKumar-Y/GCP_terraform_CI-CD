terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.27.0"
    }
  }
  backend "gcs" {                  // this backend block terraform for github actions CI
    bucket = "state-file-mt4015"
    prefix = "influxvm-statefile"
  }


//  backend "gcs" {                // This backend is for azure devops CI/CD
//    bucket = "$(bucket_name)"
//    prefix = "$(backend_value)-statefile"
//    credentials = "serviceaccount.json"
//
//  }
}
