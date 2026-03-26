output "connect_command" {
  value = "gcloud compute ssh ${google_compute_instance.private_server.name} --zone=${google_compute_instance.private_server.zone} --tunnel-through-iap --project=${var.project_id}"
}
