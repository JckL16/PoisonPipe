FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://gitea.com/gitea/tea/releases/download/v0.14.1/tea-0.14.1-linux-amd64 \
    -o /usr/local/bin/tea \
    && chmod +x /usr/local/bin/tea

RUN git config --global user.email "attacker@corp.local" \
    && git config --global user.name "Attacker"

COPY attack/attack.sh /attack.sh
RUN chmod +x /attack.sh

CMD ["/attack.sh"]
