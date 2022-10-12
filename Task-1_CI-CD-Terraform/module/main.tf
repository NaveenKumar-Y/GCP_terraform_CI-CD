
resource "google_compute_instance" "default" {
  name = var.vm_name
  machine_type = var.machine_type
  zone = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = var.network_name

    access_config {
      // Ephemeral public IP
      nat_ip = "${google_compute_address.external_ip.address}"
    }
  }

  metadata_startup_script = file("${path.root}/startup_script_postgres.sh")
  
  service_account {
    email  = "tachyons-srv-acc@gcp-hum-tachyons.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}


resource "google_compute_address" "external_ip" {
  name         = "gce-address-external-static"
  zone         = var.zone
}
