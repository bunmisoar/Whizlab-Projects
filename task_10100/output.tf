output "db_instance_endpoint" {
  value       = aws_db_instance.myinstance.endpoint     
}

output "web_instance_ip" {
    value = aws_instance.web-server.public_ip     
}
