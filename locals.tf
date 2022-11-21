locals {
    bucket_name_landing = "${var.project_id}_${var.gcs_bucket_name_landing}" #var.project_id + "_" + var.gcs_bucket_name_landing
    # tenant_environment = "${var.tenant}_${var.environment}" example.
    bucket_name_transcribed = "${var.project_id}_${var.gcs_bucket_name_transcribed}" #var.project_id + "_" + var.gcs_bucket_name_transcribed
}