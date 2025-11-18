#FROM jenkins/jenkins:lts-jdk17
FROM jenkins/agent:alpine
USER root
RUN apk update && apk add python3 py3-pip
RUN apk update && apk add --no-cache \
    python3 py3-pip \
    curl \
    docker-cli
# RUN apt-get update && apt-get install -y lsb-release python3-pip
# RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
#   https://download.docker.com/linux/debian/gpg
# RUN echo "deb [arch=$(dpkg --print-architecture) \
#   signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
#   https://download.docker.com/linux/debian \
#   $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
# RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
# RUN jenkins-plugin-cli --plugins "blueocean:1.25.3 docker-workflow:1.28"

