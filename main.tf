data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = var.vpc_workspace
  config = {
    region         = "eu-central-1"
    acl            = "private"
    profile        = var.aws_profile
    bucket         = var.vpc_s3_state
    key            = "terraform.tfstate"
    dynamodb_table = var.vpc_s3_state
  }
}

# TODO currently all non-string and remote data values are taken from locals
#  - this should be replaced by a dynamic logic
#  - making it possible to only having to define values in the *.tfvars instance 
#    config rather than in two places!!
module "ec2_public" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  create = length(var.instances_public) > 0 ? true : false

  for_each = var.instances_public

  name = "${local.name}-${each.key}-${random_string.name.result}"

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  key_name                    = local.key_name
  availability_zone           = local.public_add[index(keys(var.instances_public), each.key)].availability_zone
  subnet_id                   = local.public_add[index(keys(var.instances_public), each.key)].subnet_id
  vpc_security_group_ids      = local.public_add[index(keys(var.instances_public), each.key)].vpc_security_group_ids
  associate_public_ip_address = local.public_add[index(keys(var.instances_public), each.key)].associate_public_ip_address

  user_data_base64            = base64encode(local.public_add[index(keys(var.instances_public), each.key)].user_data)
  user_data_replace_on_change = local.public_add[index(keys(var.instances_public), each.key)].user_data_replace_on_change

  tags = merge(local.tags, each.value.tags)

}

module "ec2_private" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  create = length(var.instances_private) > 0 ? true : false

  for_each = var.instances_private

  name = "${local.name}-${each.key}-${random_string.name.result}"

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  key_name                    = local.key_name
  availability_zone           = local.private_add[index(keys(var.instances_private), each.key)].availability_zone
  subnet_id                   = local.private_add[index(keys(var.instances_private), each.key)].subnet_id
  vpc_security_group_ids      = local.private_add[index(keys(var.instances_private), each.key)].vpc_security_group_ids
  associate_public_ip_address = false

  user_data_base64            = base64encode(local.private_add[index(keys(var.instances_private), each.key)].user_data)
  user_data_replace_on_change = local.private_add[index(keys(var.instances_private), each.key)].user_data_replace_on_change

  tags = merge(local.tags, each.value.tags)

}

resource "aws_key_pair" "tf-key-pair" {
  key_name   = local.key_name
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "${path.module}/artifacts/${local.name}.pem"
}

resource "null_resource" "tf-key" {
  provisioner "local-exec" {
    command = "chmod 400 ${path.module}/artifacts/${local.name}.pem"
  }

  depends_on = [
    local_file.tf-key
  ]
}

// TODO: upload artifacts to s3 bucket - actually, use official module terraform-aws-s3-bucket
# resource "aws_s3_bucket_object" "artifacts" {
#   for_each = fileset("${path.module}/artifacts", "*")
#   bucket = aws_s3_bucket.artifacts.id
#   key = each.value
#   source = "${path.module}/artifacts/${each.value}"
#   etag = filemd5("${path.module}/artifacts/${each.value}")
# }


