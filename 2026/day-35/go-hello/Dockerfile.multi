FROM golang:1.23 AS builder

WORKDIR /app

COPY main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -o app main.go

FROM alpine:3.20

RUN adduser -D appuser

COPY --from=builder /app/app /app/app

USER appuser

EXPOSE 8080

CMD ["/app/app"]
