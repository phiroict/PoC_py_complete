# PoC Jenkins - K8s - ArcoCD integration 

The project is a PoC and a Tutorial for setting up Kubernetes with a Jenkins CI pipeline and ArgoCD as CD solution.
It will go into deploying namespaces by environment in k8s and assure the ancillary components. 

The high level flow is
![High_Level_Flow](docs/High%20level%20flow.jpg)

The application is split over two repos, one (`app repo`) that contains the source code and the container build instructions, 
the other (`infra repo`) has the infrastructure
manifests for k8s in the Kustomize format. 
The CI picks up the `app repo` and builds the image. The image sha256 is then pushed into the `infra repo` that is monitored by the 
CD that will apply the changes on the k8s cluster. 


This PoC handles with the integration of Jenkins with argoCD in conjunction by order of infra git repo updates on a k8s cluster. 


Confused? You won't be after this PoC! [Cue music](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=video&cd=&cad=rja&uact=8&ved=2ahUKEwimydTsvZPzAhWaf30KHU-fCLwQtwJ6BAgHEAM&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D0BHQT3Omqtw&usg=AOvVaw3WgRyttiZzPO7aB40GuhsW)!

# Axioms

- The example is based on the idea of GitOps, where infrastructure and code are held in separate git repos. Some items like PRs have been omitted from the PoC. This 
project aims to showcase some modern CI and CD tools on Kubernetes. No doubt there are other ways of doing this, this is one of them. 
The idea is that a branch in the app code translates to a deploy in the kubernetes cluster. So the `app repo` dev branch will trigger a `dev` pipeline that will deploy to a `dev` namespace in the cluster.

# Stack
- Minikube - a very simple one node k8s cluster that runs on your local VM stack, it will be the `Kubernetes` part.
- ArgoCD - A GitOps tool that runs on k8s, this will run the `CD` part. 
- Make - That builds most of the environment for this PoC
- Jenkins - Whose pipelines run the `CI` part
- Python - A very simple front and back app for the showcase. 
- kubectl - Kubernetes command line for interacting with the system, installed together with minikube and configured when running it.
- Kustomize - a wrapper around environment separation for kubernetes manifests. 

# Setup

## Source of this PoC
Get the project, make sure you take the submodules with it.

`git clone --recurse-submodules -j8 git@github.com:phiroict/PoC_py_complete.git`

## Components used
The components are: 
- GIT: Backend, Frontend : Two Apps + Dockerfile build file 
- CI : Jenkins container and utils
- GIT: infra : Two projects, Kustomize projects for backend and frontend
- Builder: Make file that builds most the apps (there is a separate in the ci folder)
- Docker: To build the image

Run `run init` to create some folders we need later. 


# Pre reqs


## Minikube

This PoC is based on minikube, install this first together with kubectl and argocd commandline. If you have another k8s cluster 
onprem of in the cloud, you would need to point to that cluster and skip the minikube part. 

See [here](https://minikube.sigs.k8s.io/docs/start/)  
Install and then start with: 

```bash
minikube start
```
Get the dashboard with: 
```bash
nohup minikube dashboard& 
```
## Kustomize 

Install with 

```bash
sudo yay -S kustomize
```
or look [here](https://kustomize.io/)

kubectl also has an inbuild kustomize app, called with `kubectl kustomize -k <manifest>` but it is old and apparently no longer really supported.

## Install argocd
Commandline (archlinux) or look at this [site](https://argoproj.github.io/argo-cd/getting_started/) for instructions for your environment: 
```bash
yay -S argocd
```

Install the kubernetes argocd set (Note that your kubectl should point to the target cluster, this is done for you when using minikube)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Create loadbalancer and export the ports

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
or do port forwarding when using minikube:

```bash
kubectl port-forward svc/argocd-server -n argocd 8082:443
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
argocd login localhost:8082
```
or in one go, note it is insecure as we did no install the certificates.

```bash
argocd login localhost:8082 --insecure --username admin --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
```

And open the site: 
```bash
nohup firefox http://localhost:8082& 
```

More info about argocd at:
```bash
https://argoproj.github.io/argo-cd/getting_started/
```

## Setting up argocd

Select a repo and upload a ssh key to the git repo if you do not have these. Do not use a passphrase as argocd does not support that. 
```bash
ssh-keygen -t ecdsa -b 521

# If your git provider does not support the eliptical curve keys, use the older rsa one

ssh-keygen -t rsa -b 4096
```

First add the repos (replace with yours if you do not want to use the PoC ones, do not forget to point to your private key)




```bash
argocd repo add git@github.com:phiroict/PoC_py_backend_infra.git --ssh-private-key-path /home/phiro/.ssh/id_rsa_poc_jenkins
argocd repo add git@github.com:phiroict/PoC_py_frontend_infra.git --ssh-private-key-path /home/phiro/.ssh/id_rsa_poc_jenkins
```

Now create the argocd applications 
We need the infra projects for these: 

```bash
argocd app create cd-backend-prod --repo git@github.com:phiroict/PoC_py_backend_infra.git --path kustomize/overlays/prod --dest-server https://kubernetes.default.svc --dest-namespace gitops-demo-prod
argocd app create cd-frontend-prod --repo git@github.com:phiroict/PoC_py_frontend_infra.git --path kustomize/overlays/prod --dest-server https://kubernetes.default.svc --dest-namespace gitops-demo-prod
argocd app create cd-backend-nonprod --repo git@github.com:phiroict/PoC_py_backend_infra.git --path kustomize/overlays/nonprod --dest-server https://kubernetes.default.svc --dest-namespace gitops-demo-nonprod
argocd app create cd-frontend-nonprod --repo git@github.com:phiroict/PoC_py_frontend_infra.git --path kustomize/overlays/nonprod --dest-server https://kubernetes.default.svc --dest-namespace gitops-demo-nonprod
argocd app create cd-backend-dev --repo git@github.com:phiroict/PoC_py_backend_infra.git --path kustomize/overlays/dev --dest-server https://kubernetes.default.svc --dest-namespace gitops-demo-dev --sync-policy auto
argocd app create cd-frontend-dev --repo git@github.com:phiroict/PoC_py_frontend_infra.git --path kustomize/overlays/dev --dest-server https://kubernetes.default.svc --dest-namespace gitops-demo-dev --sync-policy auto

```

## Jenkins setup

Run the `make build` and `make run` tasks from the `ci/jenkins/container` 

The process ends with a temporary password for the `admin` user. Log in and install the recommended plugins, set the account password   
Note that this container uses a volume to store the settings so you need to do the setup once until you delete the volume.  


Now define an agent to a machine that runs docker, for the PoC this would be the host machine on `172.17.0.1` create an ssh keypair and add the public,
this omits the need to run docker in docker. It is also bad form to run any pipeline on the Jenkins master. (Though I assume they 
have an opinion to connect up to the docker host to run the agents, c'est la vie)  

key to the `authorized_keys` file while setting up the agent with ssh, username and ssh keypair. 
Note that the authorized_keys file needs to be in `0400` mode to have ssh read it.
As agent folder select the `ci/jenkins/agent-smith` as this one is already excluded from storing in git. 


On start install the following plugins (We need them for the pipelines)
```bash
jenkins-plugin-cli --plugins basic-branch-build-strategies bitbucket build-name-setter checkmarx cobertura copyartifact docker-workflow htmlpublisher http_request job-dsl kubernetes kubernetes-cli kubernetes-credentials performance sonar ssh-credentials templating-engine ws-cleanup xunit pipeline-utility-steps
```
Or install these by the GUI plugins installer, whatever serves you best. 


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

### Create pipelines. 

There are two pipelines defined in the `ci/jenkins/pipelines/backend` and `ci/jenkins/pipelines/frontend`
In jenkins create the two pipelines. 
Like this: 
![Pipeline configuration](docs/pipeline-jenkins-dsl.png)

Keep all the default values, you may add a description, we add scheduling later. 

Do the same for the other one but replace the Pipeline Template Path to `ci/jenkins/pipelines/frontend/Jenkinsfile` 
Name the first one `CI-backend` and the other `CI-frontend`. The rest of the docs refers to these names so if you choose another name, remember and map these names.  

# Plan PoC
## diagram


![Diagram](docs/design_app.jpg)



# Starting and stopping stack after setup
## Quick reload
When all is setup these are the steps to start the stack.
Assumes all the prereqs set up;
```bash
make start_stack
```

And then to log in on argocd commandline
```bash
make argo_login
```
Stop the stack with

```bash
make stop_stack
```

The make `start_stack` action executes these steps:


```bash
# Start the host services
make workspace_init

# Start minishift
minikube start

# Start dashboard
nohup minikube dashboard & 

# In separateshell, forward arcocd port
nohup kubectl port-forward svc/argocd-server -n argocd 8082:443&

# Open browser for argocd
nohup firefox http://localhost:8082&

# start Jenkins 
cd ci/jenkins/container && make run 

# login 
nohup firefox http://localhost:8081& 
```


# Components Apps (git)

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


# Test and access 

Export the services with: 

```bash
minikube tunnel
```

Or through the loadbalancer when you have your own k8s cluster.  

Exports (from the services page) Note that your ip addresses will be different, you can get them from the services page)
- dev: http://10.98.20.103:5000/
- nonprod: http://10.110.11.224:5000/
- prod: http://10.99.133.247:5000/

# Cleanup

## Delete gitops projects


Note that the cascade flag will instruct argocd to delete all components it has created, this will also delete other components 
that are installed as children so in real life you'd not use this way. Only when you truly want to get rid of all components and all 
adjacent components. 

```bash
argocd app delete cd-frontend-prod --cascade -y
argocd app delete cd-backend-prod --cascade -y
argocd app delete cd-frontend-nonprod --cascade -y
argocd app delete cd-backend-nonprod --cascade -y
argocd app delete cd-frontend-dev --cascade -y
argocd app delete cd-backend-dev --cascade -y
```
