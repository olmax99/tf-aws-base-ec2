output "ec2-public-all" {
  value = module.ec2_public
}

output "ec2-private-all" {
  value = module.ec2_private
}

output "ec2-public-private-ip" {
  value = zipmap([for k, v in module.ec2_public : format("%s", k)], [for k, v in module.ec2_public : v.private_ip])
}

output "ec2-public-public-ip" {
  value = zipmap([for k, v in module.ec2_public : format("%s", k)], [for k, v in module.ec2_public : v.public_ip])
}

// user_data needs to be set individually
output "cloudinit_cloud_config" {
  description = "Content of the cloud-init config to be deployed to a server."
  value       = data.cloudinit_config.config.rendered
}

output "cloudinit_environment_variables" {
  value = local.environment
}

output "cloudinit_included_files" {
  value = toset([for f in local.cloudinit_files : f.filename])
}
