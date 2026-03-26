resource "google_project_iam_member" "iap_access" {
  project    = var.project_id
  role       = "roles/iap.tunnelResourceAccessor"
  member     = "user:${var.developer_email}"
  depends_on = [google_project_service.iap]
}
