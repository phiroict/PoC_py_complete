# Development environment

This will create the development environment for this tutorial on AWS. 
Note that you need an AWS account and a key and secret to that account. 


# Stack 

- aws-vault
- terraform  0.12+
- packer
- aws cli
- ssh (macox/linux) / putty (windows)
- tigevnc client 
- ansible *1
- visual code

You need to install the components of the set, and be comfortable in its use.  
*1 Ansible does not work on windows, it is used for bootstrapping the development system which is linux, knowledge of 
ansible is useful for analysing the provision playbook but has no further usage in this tutorial. 


We use terraform to create our development environment. 
For this we create the VPC, a subnet with an internet gateway and the EC2 instance. This will be a linux instance we 
provision with a display server and the tools needed to be installed.



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
### Generated AMI 
(yours will be different) after the run of the initial tasks,  you have an ami with the setup here. 

AMI generated is: `ami-0eeffff38b12dee7e`
Now, you do not need to pass it to the provisioner, it will look for the AMI Name `ubuntu-linux-dev-machine` we created 
earlier. 

Now build the development machine with 

```bash
make build_dev_machine
```

Tear it down with 

```bash
make delete_dev_machine
```
Note that deleting the machine will remove all storage attached to it so make sure all your work is either in git 
or on an attached storage device that is not managed by terraform. 
