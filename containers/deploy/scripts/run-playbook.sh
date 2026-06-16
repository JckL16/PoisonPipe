#!/bin/bash
set -e

# All this output will be written to /var/log/ansible-deploy.log by the cronjob script
REPO_DIR="/home/deploy/infra-pipeline"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting deployment run"

if [ -d "$REPO_DIR/.git" ]; then
    git -C "$REPO_DIR" pull
fi

ansible-playbook -i "$REPO_DIR/inventory.ini" "$REPO_DIR/playbook.yml"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Deployment complete"
