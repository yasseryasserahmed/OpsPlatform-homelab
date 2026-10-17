#!/bin/bash
# scripts/create_ansible_inventory.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/../terraform/environments/lab"
OUT_FILE="$SCRIPT_DIR/../ansible/inventory.ini"

SSH_USER="ubuntu"
SSH_KEY="~/.ssh/ec2_homelab_controlplane.pem"


WORKERS=(
  "lab-node-worker-1:worker_1"
  "lab-node-worker-2:worker_2"
)

# --- control plane ---
public_ip=$(terraform -chdir="$TF_DIR" output -raw control_plane_public_ip)
private_ip=$(terraform -chdir="$TF_DIR" output -raw control_plane_private_ip)
instance_id=$(terraform -chdir="$TF_DIR" output -raw control_plane_instance_id)

# --- workers ---
worker_hosts=""
for entry in "${WORKERS[@]}"; do
  name="${entry%%:*}"
  prefix="${entry##*:}"

  w_public_ip=$(terraform -chdir="$TF_DIR" output -raw "${prefix}_public_ip")
  w_private_ip=$(terraform -chdir="$TF_DIR" output -raw "${prefix}_private_ip")
  w_instance_id=$(terraform -chdir="$TF_DIR" output -raw "${prefix}_instance_id")

  worker_hosts+="${name} ansible_host=${w_public_ip} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY} private_ip=${w_private_ip} instance_id=${w_instance_id}"$'\n'
done

mkdir -p "$(dirname "$OUT_FILE")"

cat > "$OUT_FILE" <<EOF
[control_plane_instance]
control-plane-instance ansible_host=${public_ip} ansible_user=${SSH_USER} ansible_ssh_private_key_file=${SSH_KEY}


[worker_nodes]
${worker_hosts%$'\n'}


[k8s_nodes:children]
control_plane_instance
worker_nodes


[control_plane_instance:vars]
private_ip=${private_ip}
instance_id=${instance_id}
EOF

echo "Inventory written to $OUT_FILE"