provider "google" {
  version = "4.27.0"
  project = var.project_name
  credentials = file("serviceaccount.json")
}