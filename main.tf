module "gce" {
  source = "./module"
  machine_type = "$(machine_type)"
  vm_name = "$(vm_name)"
  zone = "$(zone)"
  image = "$(boot_image)"
  network_name = "$(network_name)"
}
