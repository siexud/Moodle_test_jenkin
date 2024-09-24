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

resource "docker_network" "moodle_network" {
  name = "moodle_network"
}

resource "docker_image" "moodle" {
  name = "bitnami/moodle:4.2.2"  # Asegúrate de que esta etiqueta sea válida
}

resource "docker_container" "mariadb" {
  name  = "${var.moodle_name}_db"
  image = "bitnami/mariadb:10.6"
  networks_advanced {
    name = docker_network.moodle_network.name
  }

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
  networks_advanced {
    name = docker_network.moodle_network.name
  }

  env = [
    "MOODLE_DATABASE_TYPE=mariadb",
    "MOODLE_DATABASE_HOST=${docker_container.mariadb.name}",
    "MOODLE_DATABASE_NAME=${var.db_name}",
    "MOODLE_DATABASE_USER=${var.db_user}",
    "MOODLE_DATABASE_PASSWORD=${var.db_password}",
  ]

  ports {
    internal = 80
    external = 8080
  }

  depends_on = [
    docker_container.mariadb,
  ]

}


