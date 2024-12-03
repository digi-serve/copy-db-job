FROM alpine:3.20.3

# install mysql
RUN apk update && \
    apk add mysql mysql-client

RUN mkdir -p /app

WORKDIR /app
