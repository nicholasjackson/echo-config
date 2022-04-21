FROM golang:latest as build

RUN mkdir -p /go/src/github.com/nicholasjackson/echo-config
COPY . /go/src/github.com/nicholasjackson/echo-config
WORKDIR /go/src/github.com/nicholasjackson/echo-config

RUN go get ./... && CGO_ENABLED=0 GOOS=linux go build -o ./bin/echo-config

FROM alpine:latest 

RUN apk add --no-cache curl bash

ARG TARGETARCH

COPY --from=build /go/src/github.com/nicholasjackson/echo-config/bin/echo-config /bin/echo-config
COPY --from=build /go/src/github.com/nicholasjackson/echo-config/start_echo_config.sh /bin/start_echo_config.sh
COPY --from=build /go/src/github.com/nicholasjackson/echo-config/config.json /config.json

RUN chmod +x /bin/start_echo_config.sh

# Install Vault for vault agent
RUN curl -L https://releases.hashicorp.com/vault/1.10.0/vault_1.10.0_linux_${TARGETARCH}.zip -o /tmp/vault.zip && \
  cd /tmp && \
  unzip vault.zip  && \
  mv vault /bin/vault

ENTRYPOINT [ "/bin/start_echo_config.sh" ]
CMD [ "--config-file","/config.json" ]