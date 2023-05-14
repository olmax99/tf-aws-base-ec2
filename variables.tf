//Global variables
variable "project" {
  type = string
}

variable "slug_version" {
  type = string
}

variable "env" {
  type = string
}

variable "aws_profile" {
  type      = string
  sensitive = true
}

variable "vpc_s3_state" {
  type = string
}

variable "vpc_workspace" {
  type = string
}

variable "initial_ssh_ip" {
  type = string
  validation {
    condition     = can(cidrnetmask(var.initial_ssh_ip))
    error_message = "Must be a valid IPv4 CIDR block address."
  }
  default = "0.0.0.0/0"
}

variable "instances_public" {
  type = map(object({
    ami           = string
    instance_type = string
    tags          = map(string)
  }))
  default = {}
}

variable "instances_private" {
  type = map(object({
    ami           = string
    instance_type = string
    tags          = map(string)
  }))
  default = {}
}

resource "random_string" "name" {
  length  = 6
  special = false
  upper   = false
}

variable "envvars" {
  description = "List of environment variables (KEY=VAL) to be made available for cloudinit"
  type        = map(string)
  default     = {}
}

// TODO: Evaluate move user_data to separate module and input directly
// Generate cloud-init config and write to /var/artifacts
data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-init.yaml"
    merge_type   = "list(append)+dict(no_replace,recurse_list)+str()"
    content_type = "text/cloud-config"
    // provide cloud-config and all additional files required for cloud-init execution
    content = templatefile("${local.template_dir}/cloud-config.yaml", {
      files = local.cloudinit_files
    })
  }
}

locals {
  name         = "${var.project}-${var.slug_version}-${var.env}"
  aws_region   = "eu-central-1"
  template_dir = "${path.module}/artifacts/templates"
  environment = merge({
    MYVAR = "placeholder"
  }, var.envvars)

  key_name = "${local.name}-key-${random_string.name.result}"
  # TODO Merge with instances configs dynamically
  # NOTE: length need to match with instance configs - currently it merges with instances_public
  public_add = [
    {
      availability_zone           = element(data.terraform_remote_state.vpc.outputs.vpc_azs, 0)
      subnet_id                   = element(data.terraform_remote_state.vpc.outputs.public_subnets, 0)
      vpc_security_group_ids      = [module.security_group_public.security_group_id]
      associate_public_ip_address = true
      user_data                   = data.cloudinit_config.config.rendered
      user_data_replace_on_change = true
    }
  ]

  private_add = [
    {
      availability_zone           = element(data.terraform_remote_state.vpc.outputs.vpc_azs, 0)
      subnet_id                   = element(data.terraform_remote_state.vpc.outputs.private_subnets, 0)
      vpc_security_group_ids      = [module.security_group_private.security_group_id]
      user_data                   = data.cloudinit_config.config.rendered
      user_data_replace_on_change = true
    }
  ]

  // limited to max 64kB!
  cloudinit_files = concat(
    [
      {
        filename = ".env"
        content  = base64encode(join("\n", [for k, v in local.environment : "${k}=${v}" if v != null]))
      },
    ],
  )

  tags = {
    terraform    = "true"
    pipeline     = "false"
    environment  = var.env
    Project_name = local.name
    project_user = "placeholder"
  }
}
