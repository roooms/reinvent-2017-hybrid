provider "google" {
  project = "hashicorp-reinvent"
  region  = "us-west1"
}

# Local resources
resource "google_compute_health_check" "default" {
  name                = "reinvent-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "${var.configuration_name}-global-forwarding-rule"
  target     = "${google_compute_target_http_proxy.default.self_link}"
  port_range = "80"
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.configuration_name}-http-proxy"
  url_map = "${google_compute_url_map.default.self_link}"
}

resource "google_compute_url_map" "default" {
  name            = "${var.configuration_name}-url-map"
  default_service = "${google_compute_backend_service.default.self_link}"
}

resource "google_compute_backend_service" "default" {
  name          = "${var.configuration_name}-region-backend-service"
  health_checks = ["${google_compute_health_check.default.self_link}"]

  backend {
    group = "${google_compute_region_instance_group_manager.default.instance_group}"
  }
}

resource "google_compute_region_instance_group_manager" "default" {
  name               = "${var.configuration_name}"
  base_instance_name = "web-server"
  instance_template  = "${google_compute_instance_template.default.self_link}"
  region             = "us-west1"
  target_size        = 3
  depends_on         = ["google_compute_instance_template.default"]

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_instance_template" "default" {
  machine_type            = "f1-micro"
  tags                    = ["http-server"]
  can_ip_forward          = "true"
  metadata_startup_script = "${data.template_file.web_server_google.rendered}"

  network_interface {
    network       = "default"
    access_config = [{}]
  }

  disk {
    auto_delete  = true
    boot         = true
    source_image = "centos-cloud/centos-7"
    type         = "PERSISTENT"
    disk_type    = "pd-ssd"
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/devstorage.full_control",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Data sources
data "template_file" "web_server_google" {
  template = "${file("${path.module}/web-server.tpl")}"
}

# Outputs
output "gcp-lb" {
  value = "${google_compute_global_forwarding_rule.default.ip_address}"
}
