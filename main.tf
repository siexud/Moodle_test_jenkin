terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "moodle" {
  name = "bitnami/moodle:latest"  # Cambiar a "latest" o una versión específica
}

resource "docker_container" "mysql" {
  name  = "${var.moodle_name}_db"
  image = "bitnami/mariadb:10.6"

  env = [
    "MARIADB_ROOT_PASSWORD=root_password",
    "MARIADB_DATABASE=${var.db_name}",
    "MARIADB_USER=${var.db_user}",
    "MARIADB_PASSWORD=${var.db_password}",
  ]

  ports {
    internal = 3306
    external = 3306
  }
}

resource "docker_container" "moodle" {
  name  = var.moodle_name
  image = docker_image.moodle.name

  env = [
    "MOODLE_DATABASE_TYPE=mysql",
    "MOODLE_DATABASE_HOST=${docker_container.mysql.name}",
    "MOODLE_DATABASE_NAME=${var.db_name}",
    "MOODLE_DATABASE_USER=${var.db_user}",
    "MOODLE_DATABASE_PASSWORD=${var.db_password}",
  ]

  ports {
    internal = 80
    external = 8005
  }
}

