# Work 

# Use

Get the project, make sure you take the submodules with it.

`git clone --recurse-submodules -j8 git@github.com:phiroict/PoC_py_complete.git`

# Pre reqs

### Install argocd

```bash
yay -S argocd
```

Install the kubernetes set

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Create loadbalancer and export the ports

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
or port forwarding:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Now get the secret for login

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
Get the server ips (for instance):
```text
kubectl get services -n argocd

# Take the one for the argocd-server
argocd-server           ClusterIP   *10.109.77.114*   <none>        80/TCP,443/TCP               125m
```

Then logon by (for instance)
```bash
argocd login 10.109.77.114
```

or by the forwarded ports 
```bash
argocd login localhost:8080
```


More info at:
```bash
https://argoproj.github.io/argo-cd/getting_started/
```


## diagram


![Diagram](docs/design_app.jpg)

Steps to do:  
- Ok: Set up example apps according to `https://www.densify.com/kubernetes-tools/kustomize`
- Ok: Design app
- Ok: Create main project with submodules.
- Set up pipeline in make
  - Push sha to infra repo
- setup gitops to trigger the build
- Build jenkins image
- Build jenkins pipeline
- End to end test


# Components Apps 

## Frontend 

`git@github.com:phiroict/PoC_py_frontend.git`

## Backend

`git@github.com:phiroict/PoC_py_backend.git`

# Components infra

PoC_py_backend_infra

## Backend
`git remote add origin git@github.com:phiroict/PoC_py_backend_infra.git`

## Frontend
`git remote add origin git@github.com:phiroict/PoC_py_frontend_infra.git`


## Main project

git submodule add git@github.com:phiroict/PoC_py_backend.git backend
git submodule add git@github.com:phiroict/PoC_py_frontend.git frontend
git submodule add git@github.com:phiroict/PoC_py_backend_infra.git infra/backend
git submodule add git@github.com:phiroict/PoC_py_frontend_infra.git infra/frontend