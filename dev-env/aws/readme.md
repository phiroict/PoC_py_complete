# Development environment

This will create the development environment for this tutorial on AWS. 
Note that you need an AWS account and a key and secret to that account. 


# Stack 

- aws-vault
- terraform  0.12+
- packer
- aws cli
- ssh / putty
- tigevnc client 

You need to install the components of the set, and be comfortable in its use. 

We use terraform to create our development environment. 
For this we create the VPC, a subnet with an internet gateway and the EC2 instance. This will be a linux instance we 
provision with a display server and the tools needed installed. 

# Installation 

From the `dev-env/aws` folder run 

```bash
make infra_pre_build
```
This will build the infra you need to create the vm on 

Now create the vm with

```bash
make build_pre_image
```
This will return an ami image under your account for instance : `ami-0d2dd60832d9d3923`
This would be the one to instantiate and run from. 


To cleanup you delete the stack with: 
```bash
make infra_teardown
```

AMI generated is: `ami-0eeffff38b12dee7e`
