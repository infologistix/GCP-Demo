variable "project_id" {
}

variable "region" {
  default = "europe-west3"
}

variable "zone" {
  default = "europe-west3-c"
}

variable "services" {
  default = [
    "compute.googleapis.com",
    "logging.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com"
  ]
}