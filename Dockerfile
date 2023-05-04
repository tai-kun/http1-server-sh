FROM alpine:3.17.3

RUN apk add --no-cache bash socat

COPY ./bin/ /etc/serversh/bin/

EXPOSE 2980

ENTRYPOINT ["/etc/serversh/bin/entrypoint.sh"]
