name                  = "weather-app"
image                 = "docker.io/manukoli1986/weather:1.0.11"
container_port        = 8080
cpu                   = "1"
memory                = "512Mi"
min_instances         = 0
max_instances         = 1
allow_unauthenticated = true
invoker_members       = []
custom_domain         = "weather-app.mayankkoli.com"
# domain must already be verified for mk-ai-projects in Search Console before
# apply — Terraform can't do that step. Leave as `custom_domain = null` to skip
# the domain mapping (service stays reachable only at its *.run.app URL).
