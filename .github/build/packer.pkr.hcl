packer {
  required_version = "< 2.0.0"
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = ">=v1.0.0"
    }
  }
}

source "docker" "default" {
  image  = "public.ecr.aws/lts/ubuntu:focal"
  commit = true
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
  name = "default"
  sources = [
    "source.docker.default"
  ]
  provisioner "ansible" {
    groups = ["test_hosts"]
    ansible_env_vars = [
      "ANSIBLE_ROLES_PATH=../../../"
    ]
    playbook_file = "./playbook.yml"
  }

}
