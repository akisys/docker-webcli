FROM dieterreuter/gotty

ENV LANG=C.UTF-8 \
    HOME=/gotty \
    GOTTY_RELEASE="v1.0.1" \
    DC_REL="1.23.1" \
    TERM=xterm-256color

WORKDIR /root
USER root

RUN apk add --update \
    bash \
    docker \
    tmux \
    vim \
    su-exec \
    shadow \
    && rm -rf /var/cache/apk/* \
    && rm /usr/bin/docker-* \
    && rm /usr/bin/dockerd

RUN set -ex \
    && addgroup gotty \
    && adduser -h $HOME -D -s /bin/bash -G gotty gotty \
    && ( curl -L https://github.com/yudai/gotty/releases/download/$GOTTY_RELEASE/gotty_linux_amd64.tar.gz | gunzip | tar x ) \
    && mv -f ./gotty /usr/bin/gotty \
    && rm -f /gotty

RUN set -ex \
    && ( curl -L "https://github.com/docker/compose/releases/download/$DC_REL/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose ) \
    && chown root:gotty /usr/bin/docker-compose \
    && chmod +x /usr/bin/docker-compose

RUN set -ex \
    && chmod o-rwx /bin/su \
    && chmod o-rwx /sbin/su-exec

WORKDIR $HOME
EXPOSE 9081

ENV GOTTY_BIND="0.0.0.0" \
    GOTTY_PORT="9081" \
    GOTTY_OPTS="--reconnect --permit-write"

ADD ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["tmux", "new", "-A", "-s", "gotty", "/bin/bash"]

