variable "zone_id" {
  description = "Cloudflare zone ID for mayankkoli.com"
  type        = string
}

variable "subdomain" {
  description = "Subdomain label, e.g. 'projecta' for projecta.mayankkoli.com. Use '@' for the root domain."
  type        = string
}

variable "target" {
  description = "CNAME target, e.g. the Cloud Run service's default URL host (<app>-<hash>-<region-code>.a.run.app)"
  type        = string
}

variable "proxied" {
  description = "Whether Cloudflare proxies (orange-cloud) the record. Must be true to get CDN/WAF/Analytics."
  type        = bool
  default     = true
}

variable "ttl" {
  description = "TTL in seconds. Ignored (set to 1 = automatic) when proxied = true."
  type        = number
  default     = 1
}
