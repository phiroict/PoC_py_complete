# Work 

# Use

Get the project, make sure you take the submodules with it.

`git clone --recurse-submodules -j8 git@github.com:phiroict/PoC_py_complete.git`

# Pre reqs

## Minikube

This PoC is based on minikube, install this first together with kubectl and argocd commandline. 


## Install argocd

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

## Jenkins setup

Run the `make build` and `make run` tasks from the `/home/phiro/IdeaProjects/PoC_GitOps_Deploy/ci/jenkins/container` 
 

Now define an agent to a machine that runs docker, for the PoC this would be the host machine on `172.17.0.1` create an ssh keypair and add the public 
key to the `authorized_keys` file while setting up the agent with ssh, username and ssh keypair. 
Note that the authorized_keys file needs to be in `0400` mode to have ssh read it.


You need to have docker and sshd running on the node to have this working. 

### Permissions

In the scriptApproval screen add these approvals: 
```text
method groovy.lang.GroovyObject invokeMethod java.lang.String java.lang.Object
method hudson.model.Job getBuildByNumber int
method hudson.model.Run getLogFile
method jenkins.model.Jenkins getItemByFullName java.lang.String
staticMethod jenkins.model.Jenkins getInstance
staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods getText java.io.File
```



# Plan PoC
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