build:
	docker build -t phiroict/jenkins-poc:20210925 .
run:
	-docker rm -f jenkins-poc
	docker volume create jenkins_home
	docker run -d -p 8081:8080 -p 50000:50000 --name jenkins-poc --privileged -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock phiroict/jenkins-poc:20210925
	@echo "Give Jenkins a minute time to initialize"
	@sleep 60
	-docker exec -it jenkins-poc cat /var/jenkins_home/secrets/initialAdminPassword
	firefox http://localhost:8081
reset:
	-docker rm -f jenkins-poc
	-docker volume rm jenkins_home
