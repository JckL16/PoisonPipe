FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash target

RUN mkdir -p /home/target/.ssh && chown target:target /home/target/.ssh && chmod 700 /home/target/.ssh
COPY --chown=target:target shared/id_rsa.pub /home/target/.ssh/authorized_keys
RUN chmod 600 /home/target/.ssh/authorized_keys

COPY --chown=target:target flag-holder/CICD-meme.jpg /home/target/flag{pu5h_70_pr0d_4nd_pr4y}.jpg

RUN chmod 400 /home/target/flag{pu5h_70_pr0d_4nd_pr4y}.jpg

RUN ln -sf /bin/bash /bin/sh

RUN mkdir -p /run/sshd

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
