#!/bin/bash
# scripts/create_ansible_inventory.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/../terraform/environments/lab"
OUT_FILE="$SCRIPT_DIR/../ansible/inventory.ini"

public_ip=$(terraform -chdir="$TF_DIR" output -raw control_plane_public_ip)
private_ip=$(terraform -chdir="$TF_DIR" output -raw control_plane_private_ip)
instance_id=$(terraform -chdir="$TF_DIR" output -raw control_plane_instance_id)

mkdir -p "$(dirname "$OUT_FILE")"

cat > "$OUT_FILE" <<EOF
[control_plane_instance]
control-plane-instance ansible_host=${public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ec2_homelab_controlplane.pem

[control_plane_instance:vars]
private_ip=${private_ip}
instance_id=${instance_id}
EOF

echo "Inventory written to $OUT_FILE"