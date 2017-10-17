FROM python:2

ENV AWS_ACCESS_KEY_ID null
ENV AWS_SECRET_ACCESS_KEY null
ENV AWS_DEFAULT_REGION null
ENV EBS_ID null
ENV EBS_RETENTION null

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    apt-get update && \
    apt-get install -y cron jq && \
    pip install awscli && \
    rm -rf /var/lib/apt/lists/*

COPY crontab /etc/cron.d/ebs-backup
COPY run.sh /run.sh
RUN chmod 0644 /etc/cron.d/ebs-backup && touch /var/log/cron.log && chmod +x /run.sh

USER root:root
CMD env > /.env && cron && tail -f /var/log/cron.log
