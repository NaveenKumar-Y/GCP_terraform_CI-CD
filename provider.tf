provider "google" {
  version = "4.27.0"
  project = "gcp-hum-tachyons"
  credentials = file("serviceaccount.json")
}