FROM alpine:3.21

RUN apk add --no-cache \
    gitea \
    ansible \
    dcron \
    bash \
    git \
    curl \
    openssh-client \
    su-exec

RUN curl -sL https://gitea.com/gitea/tea/releases/download/v0.14.1/tea-0.14.1-linux-amd64 \
    -o /usr/local/bin/tea \
    && chmod +x /usr/local/bin/tea

# Gitea runs as "git" 
RUN adduser -D -H -s /bin/bash -u 1000 git

# Ansible script via cron as "deploy"
RUN adduser -D -s /bin/bash deploy

# Copy over the gitea config
COPY --chown=git:git deploy/config/app.ini /etc/gitea/app.ini

COPY --chown=deploy:deploy deploy/git-repo/ /home/deploy/git-repo/

# SSH key - lets the deploy OS user authenticate to flag-holder using ssh
RUN mkdir -p /home/deploy/.ssh && chown deploy:deploy /home/deploy/.ssh && chmod 700 /home/deploy/.ssh
COPY --chown=deploy:deploy shared/id_rsa /home/deploy/.ssh/id_rsa
RUN chmod 600 /home/deploy/.ssh/id_rsa

# Cron job: pull latest playbook from Gitea and apply it every 2 minutes
RUN echo '*/2 * * * * su-exec deploy /opt/run-playbook.sh >> /var/log/ansible-deploy.log 2>&1' > /etc/cron.d/ansible-deploy
COPY deploy/scripts/run-playbook.sh /opt/run-playbook.sh
RUN chmod +x /opt/run-playbook.sh

# Copy over the entrypoint script and make it executable
COPY deploy/scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
