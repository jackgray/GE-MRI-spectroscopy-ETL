FROM alpine:latest

USER root

RUN apk update && \
    apk upgrade && \
    apk add --no-cache bash

COPY /bash-app /app
WORKDIR /app

CMD bash p-pull.sh