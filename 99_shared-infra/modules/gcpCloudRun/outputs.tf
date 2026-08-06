output "uri" {
  value = google_cloud_run_v2_service.this.uri
}

output "name" {
  value = google_cloud_run_v2_service.this.name
}

output "domain_mapping_cname_target" {
  description = "CNAME target Cloudflare must point custom_domain at (typically ghs.googlehosted.com). null if custom_domain wasn't set."
  value       = length(local.domain_mapping_cname_records) > 0 ? local.domain_mapping_cname_records[0].rrdata : null
}
