output "ec2-public-id" {
  value = [for k,v in module.ec2_public: format("%s: %s", k, v.id)]
}

output "ec2-private-id" {
  value = [for k,v in module.ec2_private: format("%s: %s", k, v.id)]
}

output "ec2-public-arn" {
  value = [for k,v in module.ec2_public: format("%s: %s", k, v.arn)]
}

output "ec2-private-arn" {
  value = [for k,v in module.ec2_private: format("%s: %s", k, v.arn)]
}

output "ec2-public-private-ip" {
  value = [for k,v in module.ec2_public: format("%s: %s", k, v.private_ip)]
}

output "ec2-private-private-ip" {
  value = [for k,v in module.ec2_private: format("%s: %s", k, v.private_ip)]
}

output "ec2-public-public-ip" {
  value = [for k,v in module.ec2_public: format("%s: %s", k, v.public_ip)]
}

output "ec2-public-private-dns" {
  value = [for k,v in module.ec2_public: format("%s: %s", k, v.private_dns)]
}

output "ec2-private-private-dns" {
  value = [for k,v in module.ec2_private: format("%s: %s", k, v.private_dns)]
}

output "ec2-public-public-dns" {
  value = [for k,v in module.ec2_public: format("%s: %s", k, v.public_dns)]
}

output "ec2-public-ami" {
  value = [for k,v in module.ec2_public: format("%s: %s", k, v.ami)]
}

output "ec2-private-ami" {
  value = [for k,v in module.ec2_private: format("%s: %s", k, v.ami)]
}
