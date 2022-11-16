#
# GCP Console monitor - https://console.cloud.google.com/kubernetes/clusters/details/europe-west2-a/private-cluster-0/details?authuser=2&project=nlp-dev-6aae 
# GCP Console logs - https://console.cloud.google.com/compute/instancesDetail/zones/europe-west2-a/instances/gke-private-cluster-0-default-pool-f8e304f2-hg3p/console?port=1&authuser=2&project=nlp-dev-6aae  
#
#resource "google_service_account" "svacc-gke-ingest-0" {
#  account_id   = "svacc-gke-ingest-0"
#  display_name = "svacc-gke-ingest-0"
#}
resource "google_service_account" "svacc-gke-train-0" {
  account_id   = "svacc-gke-train-0"
  display_name = "svacc-gke-train-0"
}
/*
Error: Request `Set IAM Binding for role "roles/artifactregistry.reader" on "project \"nlp-dev-6aae\""` 
returned error: Error retrieving IAM policy for project "nlp-dev-6aae": googleapi: 
Error 403: Cloud Resource Manager API has not been used in project 301918148666 
before or it is disabled. Enable it by visiting 
https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview?project=301918148666 then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.
*/
resource "google_project_iam_binding" "artifact-registry-reader-binding" {
  role               = "roles/artifactregistry.reader"
  project            = var.project_id 
  /*
  Error: Request `Set IAM Binding for role "roles/artifactregistry.reader" on 
  "project \"nlp-dev-6aae\""` returned error: 
  Error applying IAM policy for project "nlp-dev-6aae": 
  Error setting IAM policy for project "nlp-dev-6aae": googleapi: Error 400: Service account gke_svc_acct_ingest_node_pool_0@nlp-dev-6aae.iam.gserviceaccount.com does not exist., badRequest
  */
  members = [
    "serviceAccount:svacc-gke-train-0@${var.project_id}.iam.gserviceaccount.com",
  ]
  depends_on = [google_service_account.svacc-gke-train-0]
}

resource "google_container_cluster" "model_training" {
  name     = var.cluster_name_gpu
  location = var.gke_location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  # remove_default_node_pool = true # comment out to allow node version to be set
  initial_node_count       = 1
  # Delete the default node pool
  remove_default_node_pool = true

  project        = var.project_id
 # node_locations = ["us-central1-a", "us-central1-c", "us-central1-f"]
  network        = var.network_name
  subnetwork     = var.subnet_name_gpu

  ## Added stuff below to make private 

  # This setting will make the cluster private
  private_cluster_config {
      enable_private_nodes = "true"

      # To make testing easier, we keep the public endpoint available. In production, we highly recommend restricting access to only within the network boundary, requiring your users to use a bastion host or VPN.
      enable_private_endpoint = "false"

      master_ipv4_cidr_block = "173.16.0.0/28" ## Error if overlap with existing network
  }

   ip_allocation_policy {
   # cluster_ipv4_cidr_block  = "10.32.0.0/14"
   # services_ipv4_cidr_block = "10.0.0.0/20"
   # use_ip_aliases           = "false"
  }

# Workaround for Health check Error - https://github.com/hashicorp/terraform-provider-google/issues/6842 
/*
The cluster creation hangs at the "Health Checks" portion and it looks as if the default node pool never gets created. It hangs for about 20 minutes before finally failing with the following message:
*/
#   node_version    = "1.22.12-gke.2300" # Taken from Sucessfully created GKE From Terraformer # if this works it should be a variable
    min_master_version = "1.22.12-gke.2300"
      # With a private cluster, it is highly recommended to restrict access to the cluster master
      # However, for testing purposes we will allow all inbound traffic.
 #     master_authorized_networks_config = [
 #       {
 #         cidr_blocks = [
 #           {
 #             cidr_block   = "0.0.0.0/0"
 #             display_name = "all-for-testing"
 #           },
 #         ]
 #       },
 #     ]    
}

resource "google_container_node_pool" "model_training_nodes" {
  name       = var.node_name_gpu
  location   = var.gke_location
  cluster    = google_container_cluster.model_training.name
  node_count = 1

  # GPU Specifcs are in this block
  node_config {
    preemptible  = false # cant be true for GPU
    machine_type = var.machine_type_gpu

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # This is created earlier and needs artofact registry access role granted. 
    service_account = google_service_account.svacc-gke-train-0.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    image_type      = "COS"
    guest_accelerator {
      type  = var.accelerator_type_gpu #  "nvidia-tesla-t4"
      count = 1
    }
  }

}