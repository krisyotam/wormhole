FROM golang:1.23-alpine AS builder
WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -o /wormhole

FROM alpine:3.20
COPY --from=builder /wormhole /usr/local/bin/wormhole
ENTRYPOINT ["wormhole"]
