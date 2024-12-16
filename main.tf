# VPC Network
resource "google_compute_network" "my_vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.apis]
}

# Subnet
resource "google_compute_subnetwork" "my_subnet" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.my_vpc.id
  region        = var.region
}

# Reserved Internal IP
resource "google_compute_address" "my_static_ip" {
  name         = "my-static-ip"
  region       = var.region
  subnetwork   = google_compute_subnetwork.my_subnet.id
  address_type = "INTERNAL"
}

# Firewall Rule for IAP
resource "google_compute_firewall" "allow_iap" {
  name    = "allow-iap"
  network = google_compute_network.my_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # IAP's IP range
  direction     = "INGRESS"
}

resource "google_service_account" "test" {
  account_id   = "test-sa"
  display_name = "Test Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "test_role_bindings" {
  for_each = toset([
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter"
  ])
  project = var.project_id
  member  = "serviceAccount:${google_service_account.test.email}"
  role    = each.value
}

# VM Instance
resource "google_compute_instance" "my_vm" {
  name         = "my-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.my_subnet.id
    network_ip = google_compute_address.my_static_ip.address
  }

  metadata = {
    enable-oslogin = "TRUE" # Optional: Remove if OS Login isn't required
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/logging.write"]
    email  = google_service_account.test.email
  }
}
