FROM jenkins/ssh-slave

ENV TZ Europe/Kiev

ARG PIP_OPTIONS="--no-cache --upgrade"
ARG DOCKER_COMPOSE_VERSION="1.24.0"

# install common tools
RUN \
    apt update && \
    apt install -y --no-install-recommends \
    python3-pip \
    apt-transport-https=1.4.9 \
    ca-certificates \
    curl=7.52.1-5+deb9u9 \
    gnupg2 \
    software-properties-common \
    openjdk-8-jdk

# set python3 as default interpreter
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

# install docker & docker-compose
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt update && \
    apt install -y --no-install-recommends docker-ce && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# install ansible and required python modules
COPY requirements.txt /tmp/

RUN \
    pip3 install ${PIP_OPTIONS} setuptools && \
    pip3 install ${PIP_OPTIONS} -r /tmp/requirements.txt
    mkdir /home/jenkins.ssh/ && \
    touch /home/jenkins/.ssh/known_hosts && \
    ssh-keyscan bastion.dev.internalone.com > /home/jenkins/.ssh/known_hosts
