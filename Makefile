init:
	cd frontend && mkdir -p kustomize kustomize/base kustomize/overlays kustomize/overlays/dev kustomize/overlays/nonprod kustomize/overlays/prod
	cd backend && mkdir -p kustomize kustomize/base kustomize/overlays kustomize/overlays/dev kustomize/overlays/nonprod kustomize/overlays/prod
	cd ci/jenkins && mkdir -p agent-smith
workspace_init:
	sudo systemctl start docker
	sudo systemctl start sshd
check_frontend:
	cd frontend && docker run --rm -i hadolint/hadolint < Dockerfile
check_backend:
	cd backend && docker run --rm -i hadolint/hadolint < Dockerfile
build_frontend: check_frontend
	cd frontend && docker build -t phiroict/k8s-test-frontend:20210925.0 . && docker push phiroict/k8s-test-frontend:20210925.0
build_backend: check_backend
	cd backend && docker build -t phiroict/k8s-test-backend:20210925.0 . && docker push phiroict/k8s-test-backend:20210925.0
start_stack: workspace_init
	minikube start
	nohup minikube dashboard &
	echo "Wait a minute to get minikube to initialize"
	sleep 150
	nohup kubectl port-forward svc/argocd-server -n argocd 8080:443&
	nohup firefox http://localhost:8080&
	cd ci/jenkins/container && make run
	nohup firefox http://localhost:8081&
stop_stack:
	minikube stop
argo_login:
	argocd login localhost:8080 --insecure --username admin --password $(shell kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)