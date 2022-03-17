FROM alpine:3.14

RUN apk update && \
    apk upgrade && \
    apk add git && \
    apk add go && \
    apk add make && \
    apk add make && \
    apk add rsync && \
    apk add jq && \
    git clone https://github.com/cli/cli.git gh-cli && \
    cd gh-cli && \
    make && \
    mv ./bin/gh /usr/local/bin/ && \
    apk add --no-cache git hub bash

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
