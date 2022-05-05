FROM alpine:latest

RUN apk add --update --no-cache \
  docker \
  bash \
  curl \
  openssl \
  openssh \
  git \
  git-lfs

# copy backup script
COPY backup.sh /

# copy entrypiont
COPY entrypoint.sh /

# give execution permission to scripts
RUN chmod +x /entrypoint.sh && \
    chmod +x /backup.sh && mkdir /backups

RUN echo "0 */3 * * * /backup.sh" > /etc/crontabs/root

ENTRYPOINT ["/entrypoint.sh"]


