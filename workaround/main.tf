resource "google_project_iam_member" "gke_sa_iam_2" {
  #service_account_id = google_service_account.svacc-gke-ingest-0.name - bad example
  member  = "serviceAccount:svacc-gke-ingest-0@${var.project_id}.iam.gserviceaccount.com"
  project = var.project_id
  role    = "roles/artifactregistry.reader"
}