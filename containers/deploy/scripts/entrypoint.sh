#!/bin/bash
set -e

# --- Gitea data directories ---
mkdir -p /var/lib/gitea/{data,repositories,log,custom} /etc/gitea
chown -R git:git /var/lib/gitea /etc/gitea

# --- Start Gitea (runs migrations and sets up DB schema on first boot) ---
su-exec git gitea web -c /etc/gitea/app.ini &
GITEA_PID=$!

echo "Waiting for Gitea to start..."
until curl -sf http://localhost:3000/api/v1/version >/dev/null 2>&1; do sleep 1; done
echo "Gitea ready."

UNCRACKABLE_PASSWORD="SuperSecretPasswordUncrackableMegaThousand"

# Create gitea_admin via CLI (needs admin flag, not available through API)
su-exec git gitea admin user create \
    -c /etc/gitea/app.ini \
    --username gitea_admin \
    --password "$UNCRACKABLE_PASSWORD" \
    --email admin@corp.internal \
    --admin \
    --must-change-password=false 2>/dev/null || true

su-exec git gitea admin user create \
    -c /etc/gitea/app.ini \
    --username jacklind \
    --password '12345678' \
    --email jacklind@corp.internal \
    --must-change-password=false 2>/dev/null || true

su-exec git gitea admin user create \
    -c /etc/gitea/app.ini \
    --username andand \
    --password 'password1' \
    --email andand@corp.internal \
    --must-change-password=false 2>/dev/null || true

# Wait until gitea_admin's credentials are recognised by the web server
until curl -sf -u "gitea_admin:$UNCRACKABLE_PASSWORD" \
    http://localhost:3000/api/v1/user >/dev/null 2>&1; do sleep 1; done

# Gitea 1.21+ requires explicit token scopes; generate via CLI then hand to tea
TEA_TOKEN=$(su-exec git gitea admin user generate-access-token \
    -c /etc/gitea/app.ini \
    --username gitea_admin \
    --token-name tea-token \
    --scopes "write:admin,write:user,write:organization,write:repository" \
    --raw)
tea login add --name default --url http://localhost:3000 --token "$TEA_TOKEN"

# Create the corp organisation
tea org create corp --visibility public --repo-admins-can-change-team-access 2>/dev/null || true

# Create the infra-pipeline repo under the corp org
tea repos create \
    --owner corp \
    --name infra-pipeline \
    --description "Corp infrastructure deployment" 2>/dev/null || true

# Both corp users get write access (production branch is protected)
tea api -X PUT repos/corp/infra-pipeline/collaborators/jacklind -f permission=write >/dev/null 2>&1 || true
tea api -X PUT repos/corp/infra-pipeline/collaborators/andand -f permission=write >/dev/null 2>&1 || true

# Seed the Gitea repo if it is still empty (safe to run on every restart)
REPO_EMPTY=$(tea api repos/corp/infra-pipeline | grep -c '"empty":true' || true)

if [ "$REPO_EMPTY" -gt 0 ]; then
    su-exec deploy env HOME=/home/deploy bash -c "
        git config --global user.email 'deploy@corp.internal'
        git config --global user.name 'Deploy Bot'
        mkdir -p /home/deploy/infra-pipeline
        cd /home/deploy/infra-pipeline
        git init -b production
        git remote add origin http://gitea_admin:${UNCRACKABLE_PASSWORD}@localhost:3000/corp/infra-pipeline

        cp /home/deploy/git-repo/production/inventory.ini .
        git add inventory.ini
        GIT_AUTHOR_NAME='Anders Andersson' GIT_AUTHOR_EMAIL='andand@corp.internal' \
            git commit -m 'Add inventory'

        cp /home/deploy/git-repo/production/playbook.yml .
        git add playbook.yml
        GIT_AUTHOR_NAME='Anders Andersson' GIT_AUTHOR_EMAIL='andand@corp.internal' \
            git commit -m 'Add deployment playbook'

        cp /home/deploy/git-repo/production/README.md .
        git add README.md
        GIT_AUTHOR_NAME='Anders Andersson' GIT_AUTHOR_EMAIL='andand@corp.internal' \
            git commit -m 'Add README'

        git push -u origin production

        git checkout -b development
        cp /home/deploy/git-repo/development/README.md .
        cp /home/deploy/git-repo/development/playbook.yml .
        git add README.md playbook.yml
        GIT_AUTHOR_NAME='Jack Lindberg' GIT_AUTHOR_EMAIL='jacklind@corp.internal' \
            git commit -m 'Update README and playbook for development branch'

        git push origin development
        git checkout production
    "
    sleep 2

    tea repos edit -r corp/infra-pipeline --default-branch development >/dev/null 2>&1 || true

    # Protect production branch: require PR approval from jacklind, block direct pushes
    tea api -X POST repos/corp/infra-pipeline/branch_protections \
        -d '{"rule_name":"production","required_approvals":1,"enable_approvals_whitelist":true,"approvals_whitelist_username":["jacklind"],"enable_push":false}' \
        >/dev/null 2>&1 || true
fi

# --- Start cron daemon (runs ansible deployments every 2 minutes) ---
touch /var/log/ansible-deploy.log
crond

wait $GITEA_PID
