output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.conduit_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.conduit_server.public_dns
}

output "nip_io_domain" {
  description = "Your free domain via nip.io"
  value       = "http://${aws_instance.conduit_server.public_ip}.nip.io"
}

output "ssh_command" {
  description = "Command to SSH into your EC2 instance"
  value       = "ssh -i ${var.key_pair_name}.pem ubuntu@${aws_instance.conduit_server.public_ip}"
}