FROM alpine:3.17

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
    apk add --no-cache git hub bash && \
    apk update && \
    apk upgrade && \
    apk add git && \
    apk add go && \
    apk add make && \
    apk add make && \
    apk add rsync && \
    apk add jq && \
    git clone --branch v2.34.0 https://github.com/cli/cli.git gh-cli && \
    cd gh-cli && \
    make && \
    mv ./bin/gh /usr/local/bin/

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
