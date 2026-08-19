name                  = "mk-trading"
image                 = "docker.io/manukoli1986/mk-trading:v2.0.0-33"
container_port        = 8080
cpu                   = "2"
# Puppeteer drives a real headless Chromium for the NSE scrape. At 512Mi the
# container was OOM-killed mid-request ("Navigating frame was detached", then
# SIGTERM) — Chromium alone needs ~1Gi, and 2 vCPU keeps its launch from
# dominating the request. min_instances is 0, so this costs nothing when idle.
memory                = "2Gi"
min_instances         = 0
max_instances         = 1
allow_unauthenticated = true
custom_domain         = "mk-trading.mayankkoli.com"
# domain must already be verified for mk-ai-projects in Search Console before
# apply — Terraform can't do that step. Leave as `custom_domain = null` to skip
# the domain mapping (service stays reachable only at its *.run.app URL).

# Cache persistence. Cloud Run gives each container an ephemeral filesystem and
# every cold start begins from the image, so without this the dashboard loses
# every cached fetch on each restart. Bucket lives in the same region as the
# service; its service account already holds objectAdmin on it.
gcs_bucket = "mk-trading-dashboard-cache"

# Telegram pre-open alert. The chat id is only an identifier so it lives here;
# the bot token and the alert shared-secret go in secrets.auto.tfvars.
telegram_chat_id = "762833990"

admin_emails     = "manukoli1986@gmail.com"
google_client_id = "481302070062-7nme0629e9gsumj1d6aptu5jc3ad8hbm.apps.googleusercontent.com"
# secrets (google_client_secret, anthropic_api_key) go in
# secrets.auto.tfvars, not here — see secrets.auto.tfvars.example.
