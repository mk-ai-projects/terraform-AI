---
name: terraform-infra-gen
description: Use this skill whenever MK asks to add a new AI project's infrastructure, expose a new subdomain, or wire up the Cloudflare DNS half for a project_<name> GCP Cloud Run service. Covers generating the Cloudflare-side Terraform "consuming" code — the Cloud Run / project scaffolding itself is the project-container-infra skill's job. Trigger on phrases like "add infra for project X", "expose Z on my domain", "new subdomain for project", "wire up DNS for Y".
---

# Terraform infra generator (Cloudflare half)

## Scope and non-negotiable rules

1. **Default to `plan`/`fmt`/`validate` only.** This repo has no CI/PR pipeline yet (no git remote) — MK runs `apply` themselves, or explicitly asks you to run it in the moment. Never run `apply` on your own initiative.
2. If this is a git repo with a CI pipeline set up later: work on a branch (`infra/<project-name>`), never commit to `main` directly, open a PR, and go back to never running `apply` yourself.
3. **Show the plan before asking for anything.** Run `terraform plan` locally and summarize what will be created/changed/destroyed in plain language before suggesting merge.
4. **Only touch `99_shared-infra/variables.tf`'s `projects` map** — never edit the reusable modules (`99_shared-infra/modules/cloudflare-cdn-web`, `99_shared-infra/modules/gcpCloudRun`, `99_shared-infra/modules/gcpEnvironment`) unless the user explicitly asks to change the module contract itself.
5. **Compute/Cloud Run scaffolding is not this skill's job.** If `project_<name>/infra.tf` doesn't exist yet, or its `custom_domain` isn't set, hand off to the `project-container-infra` skill first — this skill only wires the CNAME once the Cloud Run domain mapping exists.
6. **Never set `proxied = true` for these records.** They point at a Cloud Run domain mapping (`ghs.googlehosted.com`), and Cloudflare's proxy hides the real target from Google, breaking the mapping's host/cert verification — DNS-only is required, not a style choice.
7. **This step doesn't happen automatically once a project is applied.** A `project_<name>` Cloud Run service being live does NOT mean Cloudflare knows about it — the `projects` map entry is a separate, deliberate addition. If MK says a project "is done" or "is working" after applying it, that's the cue to check whether this skill's step has run yet, not assume it has.
8. **Don't `rm -rf .terraform` in `99_shared-infra` if MK might be applying there concurrently** — it's raced against a live `apply` before (wiped the provider plugin cache mid-run). Ask first, or just leave cache dirs alone; they're gitignored and harmless to leave around.

## What "adding a subdomain" means concretely

Add one entry to the `projects` map in [99_shared-infra/variables.tf](../../../99_shared-infra/variables.tf) — the key MUST match the `project_<key>` directory name exactly, that's how the CNAME target gets resolved:

```hcl
variable "projects" {
  default = {
    mk-stock-screener = {}
    # add the new project here — key = project_<key> directory name:
    projectc = {}
  }
}
```

No `target` field — [99_shared-infra/main.tf](../../../99_shared-infra/main.tf) already has `data.terraform_remote_state.projects` (for_each over this same map) that reads each `project_<key>/terraform.tfstate`'s `domain_mapping_cname_target` output (from the project's `custom_domain` / `google_cloud_run_domain_mapping` — NOT the raw `uri`) and feeds it straight into the `cloudflare-cdn-web` module's `target`. Adding the map entry is the entire diff for this skill — never hand-type a `.run.app` or `ghs.googlehosted.com` host.

### Ordering

Because the CNAME target is read from the project's own state, that state has to exist first, AND the project's `custom_domain` must already be set (which itself needs Search Console domain verification for `mk-ai-projects` — a manual prerequisite, not something Terraform can do):

- **First**: `project-container-infra` skill creates and applies `project_<name>/infra.tf` with `custom_domain` set. Once applied, `project_<name>/terraform.tfstate` has a non-null `domain_mapping_cname_target` output.
- **Second** (this skill): add the `projects` map entry. `terraform plan` here will fail with a clear "no state file" error if step one hasn't been applied yet, or produce a `null` target if `custom_domain` wasn't set on the project — either is the signal to go fix step one first, not a bug in this skill.

## Process to follow every time

1. Confirm the target project's Cloud Run service is already deployed (`domain_mapping_cname_target` output is non-null) — if not, hand off to `project-container-infra` first.
2. Create branch `infra/<project-name>` (if git repo).
3. Add the `projects` map entry in `99_shared-infra/variables.tf`, following the exact variable shape the `cloudflare-cdn-web` module expects — read `99_shared-infra/modules/cloudflare-cdn-web/variables.tf` first to confirm current inputs before writing consuming code, since the module contract may have evolved.
4. Run `terraform fmt -recursive` and `terraform validate`.
5. Run `terraform plan` and summarize the result in plain language (X to add, Y to change, Z to destroy — call out anything destructive explicitly).
6. If this is a git repo with a remote and CI/PR flow set up: commit, push, open PR with the plan summary, tell MK it's ready for review, don't merge or apply yourself. Otherwise: report the diff and validated plan, and wait to be explicitly asked before running `apply`.
