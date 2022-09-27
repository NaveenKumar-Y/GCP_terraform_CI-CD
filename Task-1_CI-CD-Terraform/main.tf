module "gce" {
  source = "./module"
  machine_type = var.machine_type
  vm_name = var.vm_name
  zone = var.zone
  image = var.boot_image
  network_name = var.network_name
}
