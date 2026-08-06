output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "run_api_id" {
  description = "Reference downstream Cloud Run resources on this via depends_on so they wait for the API to be enabled"
  value       = google_project_service.run.id
}
