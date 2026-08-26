name                  = "mk-stock-screener"
image                 = "docker.io/manukoli1986/mk-stock-screener:latest"
container_port        = 8080
cpu                   = "1"
memory                = "512Mi"
min_instances         = 0
max_instances         = 1
allow_unauthenticated = true
invoker_members       = []
custom_domain         = "mk-stock-screener.mayankkoli.com"
# ADMIN_KEY / SECRET_KEY come from Secret Manager (secrets.tf). Values live in
# secrets.auto.tfvars locally, or repo secret MK_STOCK_SCREENER_SECRETS_TFVARS in CI.
