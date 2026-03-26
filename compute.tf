resource "google_compute_instance" "private_server" {
  name         = "top-secret-db-server"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.private_network.id
    subnetwork = google_compute_subnetwork.private_subnet.id
    # No access_config block — no public IP
  }
}
