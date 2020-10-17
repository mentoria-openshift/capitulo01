FROM docker.io/maven:3.6.3-adoptopenjdk-11

ENV APP_PROFILE="default"

COPY [ "scripts/entrypoint.sh", "/entrypoint.sh" ]

RUN apt update -y
RUN apt install -y git
RUN git clone https://github.com/thaalesalves/simplecrud-spring /opt/simplecrud

WORKDIR /opt/simplecrud

RUN mvn clean install

EXPOSE 8080
ENTRYPOINT [ "sh", "/entrypoint.sh" ]