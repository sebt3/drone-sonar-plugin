FROM golang:1.20-alpine3.17 as build
RUN mkdir -p /go/src/github.com/aosapps/drone-sonar-plugin
WORKDIR /go/src/github.com/aosapps/drone-sonar-plugin 
COPY *.go ./
COPY vendor ./vendor/
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o drone-sonar

FROM openjdk:21-jdk

ARG SONAR_VERSION=4.7.0.2747
ARG SONAR_SCANNER_CLI=sonar-scanner-cli-${SONAR_VERSION}
ARG SONAR_SCANNER=sonar-scanner-${SONAR_VERSION}

RUN apt-get update \
 && apt-get install -y curl \
 && apt-get clean \
 && curl -sL "https://nodejs.org/dist/v18.15.0/node-v18.15.0-linux-x64.tar.xz" |tar -C /usr/local/ --strip-components=2 -xzf -

COPY --from=build /go/src/github.com/aosapps/drone-sonar-plugin/drone-sonar /bin/
WORKDIR /bin

RUN curl https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/${SONAR_SCANNER_CLI}.zip -so /bin/${SONAR_SCANNER_CLI}.zip
RUN unzip ${SONAR_SCANNER_CLI}.zip \
    && rm ${SONAR_SCANNER_CLI}.zip 

ENV PATH $PATH:/bin/${SONAR_SCANNER}/bin

ENTRYPOINT /bin/drone-sonar
