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
  image  = "ubuntu:jammy"
  commit = true
}

build {
  name = "default"
  sources = [
    "source.docker.default"
  ]
}
