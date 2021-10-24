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

## Set up AWS
In AWS create a user that has admin rights over EC2. Create a key and secret. 
Add these to the `home` profile in aws-vault 
```bash
aws-vault add home 
```
Follow the instructions adding the key and secret and select region `ap-southeast-2` 
Now you can log in with aws account in the below make scripts. If you create a different profile, change the names in 
the Makefiles to reflect this. 

## Build pipeline

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


# Connect 

Connect with the ssh string that the process returned for instance `ssh -i ~/.ssh/id_rsa -L 5902:127.0.0.1:5901 ubuntu@13.211.153.70` (Ip address and key location may be different) 
And then start the vnc server from within the remote session.
```bash
vncserver -geometry 1920x1040 :1
```

It will ask you to create a password for the session, make up a hard one (it is per session) and then logon with a vnc client on to the ip address 127.0.0.1 and the port (5902)
For instance: 
```bash
vncviewer 127.0.0.1:5902 
```

Why localhost? We have tunneled the vnc session over ssh to encrypt it and to avoid having to expose the vnc port to the internet. VNC is not encrypted by nature and the SSL certificate
route is a pain in the butt. So we let ssh work for us. 

Warning: Do not replace `127.0.0.1` with `localhost` as that is not the same and will not work. 





