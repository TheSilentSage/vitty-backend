# syntax = docker/dockerfile:1.2

# BUILD IMAGE
FROM golang:1.19.3-alpine3.15 AS builder
WORKDIR /usr/src/app

RUN apk update \
    && apk --no-cache --update add build-base git

COPY ./vitty-backend-api/go.mod ./vitty-backend-api/go.sum ./

# RUN go mod download && go mod verify

COPY ./vitty-backend-api .
RUN --mount=type=secret,id=_env,dst=/etc/secrets/.env  cat  /etc/secrets/.env
# RUN --mount=type=secret,id=firebase_creds_json,dst=/etc/secrets/firebase-creds.json  cp  /etc/secrets/firebase-creds.json  ./
# RUN --mount=type=secret,id=oauth2_credentials_json,dst=/etc/secrets/oauth2-credentials.json  cp  /etc/secrets/oauth2-credentials.json  ./


RUN go build -o bin/vittymod

# RUNNER IMAGE
FROM alpine:3.15 AS runner

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/bin/vitty ./bin/vitty
COPY  --from=builder /usr/src/app/firebase-creds.json /usr/src/app/oauth2-credentials.json ./credentials/
RUN apk --no-cache add tzdata
RUN chmod +x ./bin/vitty

CMD ["./bin/vitty", "run"]