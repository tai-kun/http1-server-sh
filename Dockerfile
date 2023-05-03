FROM alpine:3.17.3

RUN apk add --no-cache \
    # Core
    bash socat \
    # Utils
    curl jq

COPY ./bin/ /etc/serversh/bin/

EXPOSE 2980

ENTRYPOINT ["/etc/serversh/bin/entrypoint.sh"]
