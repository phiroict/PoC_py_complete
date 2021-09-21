init:
	cd frontend && mkdir -p kustomize kustomize/base kustomize/overlays kustomize/overlays/dev kustomize/overlays/nonprod kustomize/overlays/prod
	cd backend && mkdir -p kustomize kustomize/base kustomize/overlays kustomize/overlays/dev kustomize/overlays/nonprod kustomize/overlays/prod
check_frontend:
	cd frontend && docker run --rm -i hadolint/hadolint < Dockerfile
check_backend:
	cd backend && docker run --rm -i hadolint/hadolint < Dockerfile
build_frontend: check_frontend
	cd frontend && docker build -t phiroict/k8s-test-frontend:20210925.0 . && docker push phiroict/k8s-test-frontend:20210925.0
build_backend: check_backend
	cd backend && docker build -t phiroict/k8s-test-backend:20210925.0 . && docker push phiroict/k8s-test-backend:20210925.0
