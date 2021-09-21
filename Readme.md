# Work 

# Use

Get the project, make sure you take the submodules with it.

`git clone --recurse-submodules -j8 git@github.com:phiroict/PoC_py_complete.git`



## diagram


![Diagram](docs/design_app.jpg)

Steps to do:  
- Ok: Set up example apps according to `https://www.densify.com/kubernetes-tools/kustomize`
- Ok: Design app
- Create main project with submodules.
- Set up build pipeline in Jenkins
- Push sha to infra repo
- setup gitops to trigger the build


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