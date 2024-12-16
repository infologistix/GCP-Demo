resource "google_project_service" "apis" {
  for_each = toset(var.services)

  project = var.project_id
  service = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true # Setting this to true will cause destroy / recreate of each project on apply
}