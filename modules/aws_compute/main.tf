# AWS Compute resources for Ansible

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


################################################################# control node ###########################################################

resource "aws_instance" "control_node" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type.worker
  subnet_id                   = var.instance_subnet_id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.public_ssh_key.key_name
  vpc_security_group_ids      = [ aws_security_group.control-node-sg.id ]

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("ssh_keys")
    host = self.public_ip
  }

  provisioner "file" {
    source = "./ansible_EE_dependencies.sh"
    destination = "/home/ubuntu/ansible_EE_dependencies.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod a+x /home/ubuntu/ansible_EE_dependencies.sh",
        "sudo bash /home/ubuntu/ansible_EE_dependencies.sh ansible_EE"
    ]  
  }

  tags = merge(
    var.instance_tags,
    {
      Name = "Control-Node"
    }
  ) 
}

################################################################ control node security group #############################################################

resource "aws_security_group" "control-node-sg" {
  name        = "allow_traffic_master"
  description = "Allow inbound and outbound traffic to master node"
  vpc_id      = var.vpc_id_instance

  tags = {
    Name = "allow_master_traffic_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "control-node-sg-egress" {
  security_group_id = aws_security_group.control-node-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all ports
}

resource "aws_vpc_security_group_ingress_rule" "contol-allow_ssh_ipv4" {
  description       = "SSH from anywhere"  
  security_group_id = aws_security_group.control-node-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "contol-allow_ping_ipv4" {
  description       = "Allow ICMP from anywhere"
  security_group_id = aws_security_group.control-node-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8
  ip_protocol       = "icmp"
  to_port           = 0
}

################################################################ Worker nodes ########################################################################
resource "aws_instance" "worker-node" {
  count                       = var.worker_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type.worker
  subnet_id                   = var.instance_subnet_id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.public_ssh_key.key_name
  vpc_security_group_ids      = [ aws_security_group.worker-node-sg.id ]
  depends_on                  = [ aws_instance.control_node ]


  tags = merge(
    var.instance_tags,
    {
      Name = "Worker-${count.index + 1}"
    }
  )                                                                                                                                                                                                  
}

################################################################ Worker nodes security group #############################################################
resource "aws_security_group" "worker-node-sg" {
  name        = "allow_traffic_worker"
  description = "Allow inbound  and outbound traffic to worker nodes"
  vpc_id      = var.vpc_id_instance

  tags = {
    Name = "allow_worker_traffic_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "worker-node-sg-egress" {
  security_group_id = aws_security_group.worker-node-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all ports
}

resource "aws_vpc_security_group_ingress_rule" "worker-allow_ssh_ipv4" {
  description       = "SSH from anywhere"  
  security_group_id = aws_security_group.worker-node-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "worker-allow_ping_ipv4" {
  description       = "Allow ICMP from anywhere"
  security_group_id = aws_security_group.worker-node-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8
  ip_protocol       = "icmp"
  to_port           = 0
}

################################################################ SSH Key Pair ###############################################################
resource "aws_key_pair" "public_ssh_key" {
  key_name = "ssh_keys"
  public_key = file("ssh_keys.pub")
}
