module "gce" {
  source = "./module"
  machine_type = var.machine_type
  vm_name = var.name
  zone = var.zone
}
