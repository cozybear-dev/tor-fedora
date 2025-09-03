data "google_billing_account" "tor_fedora" {
  billing_account = var.billing_account_id 
  open            = true
}

locals {
  project_name = "tor-fedora"
}

resource "random_id" "random" {
  byte_length = 4
}

resource "google_project" "tor_fedora" {
  name       = local.project_name
  project_id = "${local.project_name}-${random_id.random.hex}"
  billing_account = data.google_billing_account.tor_fedora.id
}

resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "compute",
    "monitoring",
    "billingbudgets",
    "cloudresourcemanager",
    "iam",
    "serviceusage",
    "cloudbilling",
    "confidentialcomputing",
  ])
  project = google_project.tor_fedora.project_id
  service = "${each.value}.googleapis.com"
  disable_on_destroy = false
}

resource "google_monitoring_notification_channel" "billing_notification_channel" {
  project = google_project.tor_fedora.project_id
  display_name = "Billing Alerts Notification Channel"
  type         = "email"

  labels = {
    email_address = "gcp-billing@shadowbrokers.eu"
  }

  depends_on = [ google_project_service.enabled_apis["monitoring"] ]
}

resource "google_billing_budget" "billing_alerts" {
  billing_account = data.google_billing_account.tor_fedora.id
  display_name    = "mi familia"

  amount {
    specified_amount {
      currency_code = "EUR"
      units         = 20
    }
  }

  threshold_rules {
    threshold_percent = 0.5
  }

  threshold_rules {
    threshold_percent = 1.0
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.billing_notification_channel.id,
    ]
  }

  depends_on = [ google_project_service.enabled_apis["billingbudgets"] ]
}

# new: dedicated service account for the confidential instance
resource "google_service_account" "instance_sa" {
  account_id   = "${local.project_name}-instance-sa"
  display_name = "Service Account for confidential compute instance"
  project      = google_project.tor_fedora.project_id
}

data "ct_config" "tor_fedora" {
  content      = file("../template.butane")
  strict       = true
  pretty_print = false
}

# new: confidential compute instance in EU with Shielded VM features and example user-data
resource "google_compute_instance" "confidential_instance" {
  name         = "${local.project_name}-confidential-vm"
  project      = google_project.tor_fedora.project_id
  zone         = "europe-west1-b"
  machine_type = "n2-standard-2"

  boot_disk {
    initialize_params {
      image = "projects/fedora-coreos-cloud/global/images/family/fedora-coreos-stable"
      size  = 50
      type  = "pd-balanced"
    }
  }

  network_interface {
    # use default network; replace with specific network/subnetwork if needed
    network = "default"
    access_config {}
  }

  // Confidential VM enablement
  confidential_instance_config {
    enable_confidential_compute = true
  }

  // Shielded VM features for secure-boot, vTPM and integrity monitoring
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  // Attach the dedicated service account to the VM
  service_account {
    email  = google_service_account.instance_sa.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  metadata = {
    user-data = data.ct_config.tor_fedora.rendered
  }

  tags = ["confidential", "shielded"]

  // ensure required APIs are enabled before creating the instance
  depends_on = [
    google_project_service.enabled_apis["compute"],
    google_project_service.enabled_apis["confidentialcomputing"],
  ]
}