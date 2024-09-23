resource "docker_container" "moodle" {
  name  = var.moodle_name
  image = "bitnami/moodle:latest"
  ports {
    internal = 80
    external = 8081
  }
  env = [
    "MOODLE_DATABASE_NAME=${var.db_name}",
    "MOODLE_DATABASE_USER=${var.db_user}",
    "MOODLE_DATABASE_PASSWORD=${var.db_password}"
  ]
}
