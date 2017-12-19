# Dockerfile with Docker multi-stage builds

## Build stage
FROM golang:1.9.2 AS builder
RUN apt-get update && apt-get install -y ca-certificates git openssh-client

ENV REPO=github.com/indaco/predix-ec-configurator
ENV APP=$GOPATH/src/$REPO
WORKDIR $APP

### Install dependencies
RUN go get -d -v github.com/PuerkitoBio/goquery
RUN go get -d -v github.com/cavaliercoder/grab
RUN go get -d -v github.com/cloudfoundry-community/go-cfclient
RUN go get -d -v github.com/gorilla/mux
RUN go get -d -v github.com/mholt/archiver
RUN go get -d -v github.com/pkg/errors
RUN go get -d -v github.com/russross/blackfriday
RUN go get -d -v github.com/sourcegraph/syntaxhighlight

### Copy the README file into working directory
COPY predix-ec-configurator/README.md .

### Copy the main file into working directory
COPY predix-ec-configurator/main.go .

### Copy the config file into working directory
COPY predix-ec-configurator/config.json .

### Copy the controllers folder into working directory
RUN mkdir -p controllers
COPY predix-ec-configurator/controllers/ /go/src/github.com/indaco/predix-ec-configurator/controllers/

### Copy the ec-templates folder into working directory
RUN mkdir -p ec-templates
COPY predix-ec-configurator/ec-templates/ /go/src/github.com/indaco/predix-ec-configurator/ec-templates/

### Copy the helpers folder into working directory
RUN mkdir -p helpers
COPY predix-ec-configurator/helpers/ /go/src/github.com/indaco/predix-ec-configurator/helpers/

### Copy the public folder into working directory
RUN mkdir -p public
COPY predix-ec-configurator/public/ /go/src/github.com/indaco/predix-ec-configurator/public/

### Copy the services folder into working directory
RUN mkdir -p services
COPY predix-ec-configurator/services/ /go/src/github.com/indaco/predix-ec-configurator/services/

### Copy the views folder into working directory
RUN mkdir -p views
COPY predix-ec-configurator/views/ /go/src/github.com/indaco/predix-ec-configurator/views/

### rebuilt built in libraries and disabled cgo
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

## Final stage
FROM alpine:latest
RUN apk add --update --no-cache ca-certificates git openssh

WORKDIR /go/src/github.com/indaco/predix-ec-configurator

### Copy the README file into working directory
COPY --from=builder /go/src/github.com/indaco/predix-ec-configurator/README.md .

### Copy the binary file into working directory
COPY --from=builder /go/src/github.com/indaco/predix-ec-configurator/main .

### Copy the config file into working directory
COPY --from=builder /go/src/github.com/indaco/predix-ec-configurator/config.json .

### Copy the controllers folder into working directory
RUN mkdir -p controllers
COPY --from=builder /go/src/github.com/indaco/predix-ec-configurator/controllers/ /go/src/github.com/indaco/predix-ec-configurator/controllers/

### Copy the ec-templates folder into working directory
RUN mkdir -p ec-templates
COPY --from=builder /go/src/github.com/indaco/predix-ec-configurator/ec-templates/ /go/src/github.com/indaco/predix-ec-configurator/ec-templates/

### Copy the helpers folder into working directory
RUN mkdir -p helpers
COPY --from=builder /go/src/github.com/indaco/predix-ec-configurator/helpers/ /go/src/github.com/indaco/predix-ec-configurator/helpers/

### Copy the public folder into working directory
RUN mkdir -p public
COPY --from=builder /go/src/github.com/indaco/predix-ec-configurator/public/ /go/src/github.com/indaco/predix-ec-configurator/public/

### Copy the services folder into working directory
RUN mkdir -p services
COPY --from=builder /go/src/github.com/indaco/predix-ec-configurator/services/ /go/src/github.com/indaco/predix-ec-configurator/services/

### Copy the views folder into working directory
RUN mkdir -p views
COPY --from=builder /go/src/github.com/indaco/predix-ec-configurator/views/ /go/src/github.com/indaco/predix-ec-configurator/views/

### Run the predix-ec-configurator command when the container starts.
CMD ["./main", "--docker", "true"]

### http server listens on port 9000
EXPOSE 9000
