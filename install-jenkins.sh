#! /bin/sh
# souce -> https://www.jenkins.io/doc/book/installing/docker/

docker network create jenkins
docker run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2
  
# Customize the official Jenkins Docker image
cat <<EOF >Dockerfile
FROM jenkins/jenkins:2.462.1-jdk17
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \\
  https://download.docker.com/linux/ubuntu/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \\
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \\
  https://download.docker.com/linux/ubuntu \\
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
EOF

docker build -t myjenkins-blueocean:2.462.1-1 .

docker run \
  --name jenkins-blueocean \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.462.1-1 

sleep 5

docker cp jenkins-blueocean:/var/jenkins_home/secrets/initialAdminPassword .
initialAdminPassword=$(cat initialAdminPassword)
rm initialAdminPassword
 
echo "######################## INSTALATION COMPLATE ####################################"
echo "Browse to http://localhost:8080"
echo "Your initial Admin Password is $initialAdminPassword"
  
  

  
