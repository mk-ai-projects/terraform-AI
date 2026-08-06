name                  = "mealplan"
image                 = "docker.io/manukoli1986/mealplan-app:v0.0.19"
container_port        = 8080
cpu                   = "1"
memory                = "512Mi"
min_instances         = 0
max_instances         = 1
allow_unauthenticated = true
custom_domain         = "mealplan.mayankkoli.com"
# domain must already be verified for mk-ai-projects in Search Console before
# apply — Terraform can't do that step. Leave as `custom_domain = null` to skip
# the domain mapping (service stays reachable only at its *.run.app URL).

admin_emails     = "manukoli1986@gmail.com"
google_client_id = "194893736615-cq0qt2ca4te2gq5ebl448d95gt6p9d82.apps.googleusercontent.com"
supabase_url     = "https://qncgxjuzzgzuhxckgwei.supabase.co"
# secrets (google_client_secret, supabase_secret_key, anthropic_api_key) go in
# secrets.auto.tfvars, not here — see secrets.auto.tfvars.example.
