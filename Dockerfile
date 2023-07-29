FROM alpine:3.18

LABEL org.opencontainers.image.authors="akisys@github"

ENV LANG=C.UTF-8 \
    HOSTNAME=webshell \
    HOME=/webcli \
    RUNUSER=webcli \
    RUNGROUP=webcli \
    TTY2WEB_RELEASE="v3.0.0" \
    TERM=xterm-256color

WORKDIR /root
USER root

RUN set -ex \
    && apk add --update --no-cache \
       bash \
       docker-cli \
       docker-cli-compose \
       docker-cli-buildx \
       tmux \
       vim \
       su-exec \
       shadow \
       tini

RUN set -ex \
    && addgroup $RUNGROUP \
    && adduser -h $HOME -D -s /bin/bash -G $RUNGROUP $RUNUSER \
    && ( wget https://github.com/kost/tty2web/releases/download/$TTY2WEB_RELEASE/tty2web_linux_amd64 -O /usr/local/bin/tty2web ) \
    && chmod +x /usr/local/bin/tty2web

RUN set -ex \
    && chmod o-rwx /bin/su \
    && chmod o-rwx /sbin/su-exec \
    && chmod o+x /bin/busybox

WORKDIR $HOME
EXPOSE 9081

ENV TTY2WEB_ADDRESS="0.0.0.0" \
    TTY2WEB_PORT="9081" \
    TTY2WEB_RECONNECT="true" \
    TTY2WEB_PERMIT_WRITE="true" \
    TTY2WEB_VERBOSE="true"

ADD ./docker-entrypoint.sh /
RUN set -ex \
    && chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/sbin/tini", "/docker-entrypoint.sh"]
CMD ["tmux", "new", "-A", "-s", "webcli", "/bin/bash"]

