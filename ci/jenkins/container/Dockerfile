FROM jenkins/jenkins:lts-jdk11
ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL https://updates.jenkins.io/experimental
RUN jenkins-plugin-cli --plugins basic-branch-build-strategies bitbucket build-name-setter checkmarx cobertura copyartifact docker-workflow htmlpublisher http_request job-dsl kubernetes kubernetes-cli kubernetes-credentials performance sonar ssh-credentials templating-engine ws-cleanup xunit

