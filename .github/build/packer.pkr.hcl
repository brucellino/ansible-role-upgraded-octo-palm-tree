packer {
  required_version = "< 2.0.0"
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = ">=v1.0.0"
    }
  }
}

variable "image_version" {
  type        = string
  default     = "latest"
  description = "Version tag to be applied to the image artifact"
}

variable "reg_username" {
  type        = string
  default     = "brucellino"
  description = "Username to log into the container registry."
}

variable "reg_password" {
  type        = string
  default     = env("GH_TOKEN")
  description = "Password to log into the container registry."
}

source "docker" "default" {
  image  = "public.ecr.aws/lts/ubuntu:focal"
  commit = true
  changes = [
    "LABEL org.opencontainers.image.source https://github.com/brucellino/ansible-role-upgaded-octo-palm-tree"
  ]
  run_command = [
    "-d",
    "-i",
    "-t",
    "--name=rabbitmq-test",
    "--entrypoint=/bin/sh",
    "{{.Image}}"
  ]
}

build {
  name = "rabbitmq-test"
  sources = [
    "source.docker.default"
  ]
  provisioner "ansible" {
    groups = ["test_hosts"]
    ansible_env_vars = [
      "ANSIBLE_ROLES_PATH=../../../",
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_CONNECTION=docker",
      "ANSIBLE_REMOTE_USER=root"
    ]
    playbook_file = "./playbook.yml"
    extra_arguments = [
      "-e",
      "ansible_connection=docker ansible_host=rabbitmq-test"
    ]
  }
  post-processors {
    post-processor "docker-tag" {
      repository = "ghcr.io/brucellino/upgraded-octo-palm-tree"
      tags       = ["latest", var.image_version]
    }
    post-processor "docker-push" {
      login          = true
      login_server   = "https://ghcr.io/${var.reg_username}"
      login_username = var.reg_username
      login_password = var.reg_password
    }
  }
}
