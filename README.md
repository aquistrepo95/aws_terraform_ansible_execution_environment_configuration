# Terraform configuration to create a control node and set up an execution environment for Ansible.

## Functional Terraform infrastructure project to run a control node for Ansible Execution Environments.

## This project showcases the following concepts in Terraform:
* Deploying AWS infrastructure using Terraform to provision components like: VPC, EC2, security groups, etc.
* Deploying a control node with Ansible installed and worker nodes.

## Built with:
* Terraform
* AWS CLI
* Python venv
* Docker: Docker engine
* BASH

## This section will describe: how to deploy the infrastructure on AWS.
* Prequisite: Terraform is installed, and AWS CLI is installed and configured with keys.
* Generate private and public keys and copy them to ssh_keys and ssh_keys.pub.
  ```
  $ ssh-keygen -C "your_email@example.com" -f ssh_keys
  ```
  
* Run Terraform commands to deploy the infrastructure to AWS.
  ```
  $ terraform fmt
  $ terraform init
  $ terrafrom validate
  $ terraform apply
  ```
  NB: This may take a few minutes to complete.

* ssh to the master/control node.
  ```
  $ ssh ubuntu@$(terraform output -raw instance_public_ip_master) -i ssh_keys -v
  ``` 

* Set permission for User(Ubuntu) to access the Docker daemon socket.
  ```
  $ sudo usermod -aG docker $USER
  $ getent group docker
  $ awk -F':' '/docker/{print $4}' /etc/group
  ```
  
* Activate Python venv: This allows you to run Python-dependent software without interfering with the system's Python installation.
  ```
  $ source <name of venv>/bin/activate
  ```
* Your installation is ready to build Ansible Execution Environments (Docker images for Ansible).
* Follow instructions here: https://docs.ansible.com/projects/ansible/latest/getting_started_ee/build_execution_environment.html
* To build your first Ansible Execution Environment image.

  
