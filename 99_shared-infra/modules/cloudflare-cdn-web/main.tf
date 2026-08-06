terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "cloudflare_record" "this" {
  zone_id = var.zone_id
  name    = var.subdomain
  type    = "CNAME"
  content = var.target
  proxied = var.proxied
  ttl     = var.proxied ? 1 : var.ttl
}
