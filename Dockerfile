FROM golang:1.26-bookworm AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux \
    go build -trimpath -ldflags="-s -w" \
    -o /happ ./cmd/happ

FROM alpine:3.22

RUN apk add --no-cache ca-certificates iproute2 iptables

COPY --from=builder /happ /usr/local/bin/happ

RUN mkdir -p /data

WORKDIR /data

ENTRYPOINT ["happ", "--home", "/data"]
CMD ["connect"]
