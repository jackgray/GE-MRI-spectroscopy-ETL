FROM node:16 AS build-env

USER root
COPY /node_app /app
WORKDIR /app
RUN npm ci --only=production

# Install rsync to minimal linux then copy bin to distroless node image
FROM alpine:latest AS alpine
RUN apk --update add rsync && \
    rm -rf /var/cache/apk/*

FROM gcr.io/distroless/nodejs:16

COPY --from=build-env /app /app
COPY --from=alpine /bin /bin

WORKDIR /app

CMD ["index.mjs"]