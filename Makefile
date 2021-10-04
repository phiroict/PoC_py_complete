COMMIT_TEXT ?= "automated"
JENKINGS_BUILD_TOKEN ?= "thisisnotthetokenyouarelookingfor"
JENKINS_BUILD_USER = "sys_builder"
ENV_TARGET ?= "DEV"

init:
	cd frontend && mkdir -p kustomize kustomize/base kustomize/overlays kustomize/overlays/dev kustomize/overlays/nonprod kustomize/overlays/prod
	cd backend && mkdir -p kustomize kustomize/base kustomize/overlays kustomize/overlays/dev kustomize/overlays/nonprod kustomize/overlays/prod
	cd ci/jenkins && mkdir -p agent-smith
workspace_init:
	sudo systemctl start docker
	sudo systemctl start sshd
	git config --global push.default current
check_frontend:
	cd frontend && docker run --rm -i hadolint/hadolint < Dockerfile
check_backend:
	cd backend && docker run --rm -i hadolint/hadolint < Dockerfile
build_frontend: check_frontend
	cd frontend && docker build -t phiroict/k8s-test-frontend:20210925.0 . && docker push phiroict/k8s-test-frontend:20210925.0
build_backend: check_backend
	cd backend && docker build -t phiroict/k8s-test-backend:20210925.0 . && docker push phiroict/k8s-test-backend:20210925.0
commit_frontend:
	cd frontend && git commit -am "Frontend:: makefile commit: $(COMMIT_TEXT)" && git push && curl -X GET --user $(JENKINS_BUILD_USER):$(JENKINGS_BUILD_TOKEN) http://localhost:8081/view/$(ENV_TARGET)/job/CI-frontend-DEV/build?token=ditiseentoken
commit_backend:
	cd backend && git commit -am "Backend:: makefile commit: $(COMMIT_TEXT)" && git push && curl -X GET --user $(JENKINS_BUILD_USER):$(JENKINGS_BUILD_TOKEN)  http://localhost:8081/view/$(ENV_TARGET)/job/CI-backend-DEV/build?token=ditiseentoken
start_stack: workspace_init
	minikube start
	nohup minikube dashboard &
	echo "Wait a minute to get minikube to initialize"
	sleep 150
	nohup kubectl port-forward svc/argocd-server -n argocd 8082:443&
	nohup firefox http://localhost:8082&
	cd ci/jenkins/container && make run
	nohup firefox http://localhost:8081&
stop_stack:
	minikube stop
argo_login:
	argocd login localhost:8080 --insecure --username admin --password $(shell kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)