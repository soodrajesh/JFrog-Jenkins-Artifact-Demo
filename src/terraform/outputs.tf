output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "artifactory_public_ip" {
  value = aws_instance.artifactory.public_ip
}