terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}


provider "docker" {
  #host = "tcp://10.68.70.12:2375/"  # Ajusta según tu configuración
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "moodle" {
  name = "bitnami/moodle:name"
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
    external = 8080
  }
}

resource "docker_container" "mysql" {
  name  = "${var.moodle_name}_db"
  image = "mysql:5.7"

  env = [
    "MYSQL_ROOT_PASSWORD=root_password",
    "MYSQL_DATABASE=${var.db_name}",
    "MYSQL_USER=${var.db_user}",
    "MYSQL_PASSWORD=${var.db_password}",
  ]

  ports {
    internal = 3306
    external = 3306
  }
}
