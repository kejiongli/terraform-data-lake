terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.36.0"
    }    
  }
}

provider "google" {
  credentials = file(var.credentials_file_path)

  project = var.project_id
  region  = var.region
  zone    = var.main_zone
}

provider "google-beta" {
  credentials = file(var.credentials_file_path)

  project = var.project_id
  region  = var.region
  zone    = var.main_zone
}
/*
module "google_artifact_registry" {
  source = "./artifact-registry"

  project_id   = var.project_id
  region       = var.region
  registry_name = var.registry_name
}

module "google_networks" {
  source = "./network"
  subnet_name_gpu  = var.subnet_name_gpu
  project_id = var.project_id
  region     = var.region
  network_name = var.network_name
  subnet_name  = var.subnet_name
}
*/

module "google_global_cloud_storage" {
  source = "./gcs"

  project_id   = var.project_id
  region       = var.region
  gcs_location = var.gcs_location
  gcs_bucket_name_landing = var.gcs_bucket_name_landing
  gcs_bucket_name_transcribed = var.gcs_bucket_name_transcribed

}
/*
module "google_gke_gen" {
  source = "./gke-gen"

  project_id   = var.project_id
  region       = var.region
  gke_location = var.gke_location
  network_name = var.network_name
  cluster_name = var.cluster_name
  subnet_name  = var.subnet_name
  machine_type = var.machine_type
  node_name  = var.node_name
  gke_ingest_roles = var.gke_ingest_roles
  depends_on = [module.google_networks, module.google_global_cloud_storage]
}

module "google_gke_gpu" {
  source = "./gke-gpu"

  project_id   = var.project_id
  region       = var.region
  gke_location = var.gke_location
  network_name = var.network_name
  cluster_name_gpu = var.cluster_name_gpu
  subnet_name_gpu  = var.subnet_name_gpu
  machine_type_gpu = var.machine_type_gpu
  accelerator_type_gpu = var.accelerator_type_gpu
  node_name_gpu = var.node_name_gpu
  depends_on = [module.google_networks, module.google_global_cloud_storage]
}
## Workaround for TFProvider Error when creating Multiple Member Roles
## This causes the second role creation to occur after a brief wait
## Current Error works if TF is rerun (again, after a wait...)
module "google_gke_gen_workaround" {
  source = "./workaround"

  project_id   = var.project_id
  depends_on = [module.google_gke_gen]
}

module "google_eventarc_gcsnotif" {
  source = "./eventarc"

  project_id   = var.project_id
  gcs_bucket_name_landing = var.gcs_bucket_name_landing
  gcs_bucket_name_transcribed = var.gcs_bucket_name_transcribed
  gcs_notif_topic_name = var.gcs_notif_topic_name
  depends_on = [module.google_global_cloud_storage]
}
*/
/*
module "google_eventarc_http" {
  source = "./func-gen2-http"

  project_id   = var.project_id
  region       = var.region
  gcs_location = var.gcs_location
}

module "google_eventarc_pubsub" {
  source = "./func-gen2-pubsub"

  project_id   = var.project_id
  region       = var.region
  gcs_location = var.gcs_location
}
*/
