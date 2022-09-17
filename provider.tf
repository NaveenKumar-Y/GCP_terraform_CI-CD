provider "google" {
  version = "4.27.0"
  project = "tonal-affinity-359610"
  credentials = file("serviceaccount.json")
}