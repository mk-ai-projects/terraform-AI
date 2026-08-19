name                  = "mk-trading"
image                 = "docker.io/manukoli1986/mk-trading:v2.0.0-38"
container_port        = 8080
cpu                   = "1"
memory                = "512Mi"
min_instances         = 0
max_instances         = 1
allow_unauthenticated = true
custom_domain         = "mk-trading.mayankkoli.com"
# domain must already be verified for mk-ai-projects in Search Console before
# apply — Terraform can't do that step. Leave as `custom_domain = null` to skip
# the domain mapping (service stays reachable only at its *.run.app URL).

admin_emails     = "manukoli1986@gmail.com"
google_client_id = "481302070062-7nme0629e9gsumj1d6aptu5jc3ad8hbm.apps.googleusercontent.com"
# secrets (google_client_secret, anthropic_api_key) go in
# secrets.auto.tfvars, not here — see secrets.auto.tfvars.example.
