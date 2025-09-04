provider "aws" {
  region = var.aws_region
}

# EC2 for Jenkins
resource "aws_instance" "jenkins" {
  ami           = "ami-0abcdef1234567890"  # Replace with latest Amazon Linux 2 AMI in your region
  instance_type = "t3.micro"
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              sudo yum upgrade -y
              sudo amazon-linux-extras install java-openjdk11 -y
              sudo yum install jenkins -y
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF

  tags = {
    Name = "Jenkins-Server"
  }
}

# EC2 for Artifactory (OSS version)
resource "aws_instance" "artifactory" {
  ami           = "ami-0abcdef1234567890"  # Replace with latest Amazon Linux 2 AMI
  instance_type = "t3.medium"  # Needs more resources
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.artifactory_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y java-11-amazon-corretto-devel
              curl -O https://releases.jfrog.io/artifactory/bintray-artifactory/org/artifactory/oss/jfrog-artifactory-oss/7.71.10/jfrog-artifactory-oss-7.71.10-linux.tar.gz
              tar -zxvf jfrog-artifactory-oss-7.71.10-linux.tar.gz
              sudo mv artifactory-oss-7.71.10 /opt/jfrog
              /opt/jfrog/app/bin/artifactory.sh start
              EOF

  tags = {
    Name = "Artifactory-Server"
  }
}

# Security Group for Jenkins (port 8080)
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow inbound traffic for Jenkins"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Artifactory (port 8081, 8082)
resource "aws_security_group" "artifactory_sg" {
  name        = "artifactory-sg"
  description = "Allow inbound traffic for Artifactory"

  ingress {
    from_port   = 8081
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# S3 Bucket for Terraform State (optional)
resource "aws_s3_bucket" "tf_state" {
  bucket = "jfrog-jenkins-demo-tf-state"
  acl    = "private"
}