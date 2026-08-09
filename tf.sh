#!/usr/bin/env bash
# Run terraform init/plan/apply against a given folder under terraform-AI.
#
# Usage: ./tf.sh <folder> <plan|apply>
#   ./tf.sh 99_shared-infra plan
#   ./tf.sh project_mealplan apply
#
# 99_shared-infra: init/plan/apply run with no -var-file (nothing to pick).
# project_*:        same, but with -var-file=app.tfvars.
#
# Both cases use -chdir so you don't have to cd yourself, and both read/write
# state from the shared GCS backend (gs://mk-ai-projects-tfstate), prefixed
# by the folder name — matches how each dir was migrated off local state.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_STATE_BUCKET="mk-ai-projects-tfstate"

folder="${1:-}"
action="${2:-}"

if [[ -z "$folder" || -z "$action" ]]; then
  echo "Usage: $0 <folder> <plan|apply>" >&2
  echo "  folder: 99_shared-infra or a project_* directory name" >&2
  exit 1
fi

if [[ "$action" != "plan" && "$action" != "apply" ]]; then
  echo "Error: action must be 'plan' or 'apply', got '$action'" >&2
  exit 1
fi

dir_path="$SCRIPT_DIR/$folder"
if [[ ! -d "$dir_path" ]]; then
  echo "Error: no such directory: $dir_path" >&2
  exit 1
fi

var_file_args=()
if [[ "$folder" != "99_shared-infra" ]]; then
  if [[ ! -f "$dir_path/app.tfvars" ]]; then
    echo "Error: $dir_path/app.tfvars not found — expected for a project_* folder" >&2
    exit 1
  fi
  var_file_args=(-var-file=app.tfvars)
fi

echo "==> terraform init ($folder)"
terraform -chdir="$dir_path" init -input=false \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="prefix=${folder}"

echo "==> terraform plan ($folder)"
terraform -chdir="$dir_path" plan -input=false -out=tfplan.out "${var_file_args[@]}"

if [[ "$action" == "apply" ]]; then
  echo "==> terraform apply ($folder)"
  terraform -chdir="$dir_path" apply -input=false tfplan.out
  rm -f "$dir_path/tfplan.out"
fi
