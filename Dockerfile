FROM dieterreuter/gotty

ENV LANG=C.UTF-8 \
    HOME=/gotty \
    GOTTY_RELEASE="v1.0.1" \
    TERM=xterm-256color

WORKDIR /root

RUN apk add --update \
    bash \
    docker \
    tmux \
    && rm -rf /var/cache/apk/* \
    && rm /usr/bin/docker-* \
    && rm /usr/bin/dockerd \
    && addgroup gotty \
    && adduser -h $HOME -D -s /bin/bash -G gotty gotty \
    && chown root:docker /usr/bin/docker \
    && chmod u+s,g+rx /usr/bin/docker \
    && ( curl -L https://github.com/yudai/gotty/releases/download/$GOTTY_RELEASE/gotty_linux_amd64.tar.gz | gunzip | tar x ) \
    && mv -f ./gotty /usr/bin/gotty \
    && rm -f /gotty

WORKDIR $HOME
USER gotty

EXPOSE 9081

ENTRYPOINT ["/usr/bin/gotty", "-a", "0.0.0.0", "-p", "9081", "--reconnect", "--permit-write"]
CMD ["tmux", "new", "-A", "-s", "gotty", "/bin/bash"]

