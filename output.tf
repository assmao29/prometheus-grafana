# print the url of the  prometheus and grafana server
output "Connexion_link_for_the_prometheus_instance" {
  value     = join ("", ["http://", aws_instance.prometheus.public_ip, ":", "9090"])
}

output "Connexion_link_for_the_grafana_instance" {
  value     = join ("", ["http://", aws_instance.grafana.public_ip, ":", "3000"])
}

output "Connexion_link_for_the_client_instance" {
  value     = join ("", ["http://", aws_instance.client.public_ip, ":", "9100"])
}

output "ssh_prometheus_command" {
  value     = join ("", ["ssh -i keypairpro.pem ec2-user@", aws_instance.prometheus.public_dns])
}

output "ssh_grafana_command" {
  value     = join ("", ["ssh -i keypairpro.pem ec2-user@", aws_instance.grafana.public_dns])
}

output "ssh_client_command" {
  value     = join ("", ["ssh -i keypairpro.pem ec2-user@", aws_instance.client.public_dns])
}