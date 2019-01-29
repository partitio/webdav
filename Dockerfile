# Declared before to persist value between stages
ARG PROJECT_NAME

# Build
FROM golang:alpine as builder

ARG PROJECT_NAME
RUN apk add --no-cache git ca-certificates && \
    mkdir -p $GOPATH/src/github.com/partitio/${PROJECT_NAME} && \
    mkdir /build

WORKDIR $GOPATH/src/github.com/partitio/${PROJECT_NAME}
ADD . .

RUN CGO_ENABLED=0 go build -o /build/${PROJECT_NAME} cmd/${PROJECT_NAME}/main.go

# Create Container's Image
FROM alpine

ARG PROJECT_NAME
# Copy certs from alpine to avoid "x509: certificate signed by unknown authority"
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /build/${PROJECT_NAME} /usr/bin/${PROJECT_NAME}
COPY config.yaml /etc/webdav/config.yaml

ENV ADMIN_PASSWORD=admin

VOLUME /data

EXPOSE 8080

ENTRYPOINT ["webdav"]
