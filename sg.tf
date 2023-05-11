module "security_group_public" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-sg0-${random_string.name.result}"
  description = "Initial security group for external access to ec2 instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "bastion service access"
      cidr_blocks = var.initial_ssh_ip
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "icmp"
      cidr_blocks = var.initial_ssh_ip
    },
  ]

  # ingress_with_ipv6_cidr_blocks = [
  #   {
  #     from_port        = 8080
  #     to_port          = 8090
  #     protocol         = "tcp"
  #     description      = "User-service ports (ipv6)"
  #     ipv6_cidr_blocks = "2001:db8::/64"
  #   },
  # ]

  egress_rules = ["all-all"]

  tags = merge(local.tags, { "Purpose" = "public access" })
}

module "security_group_private" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-sg1-${random_string.name.result}"
  description = "Initial security group for internal access to ec2 instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "bastion service access"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "icmp"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
    },
  ]

  egress_rules = ["all-all"]

  tags = merge(local.tags, { "Purpose" = "Access from vpc CIDR" })
}
