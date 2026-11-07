FROM golang:1.23

WORKDIR /app

COPY main.go .
RUN go build -o app main.go

EXPOSE 8080

CMD ["./app"]
