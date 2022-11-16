## Artifact Registry - Part of CI/CD PIPELINE
# No known TF for Cloud Build
# No apparent Terraformer capability for artefact registry - odd.  
resource "google_artifact_registry_repository" "nle-repo" {
  location      = var.region
  project       = var.project_id 
  repository_id = var.registry_name
  description   = "Docker repository for NLE GCP Prototpye Data Lake"
  format        = "DOCKER"
}