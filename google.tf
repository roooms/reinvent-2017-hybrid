provider "google" {
  project = "${var.google_project}"
  region  = "${var.google_region}"
}

# Use module registry: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.0.2
module "mig" {
  source            = "GoogleCloudPlatform/managed-instance-group/google"
  region            = "${var.google_region}"
  zone              = "${var.google_zone}"
  name              = "${var.configuration_name}"
  compute_image     = "centos-cloud/centos-7"
  size              = 3
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.web_server_google.rendered}"
  target_tags       = ["allow-service", "http-server"]
}

# Data sources:
data "template_file" "web_server_google" {
  template = "${file("${path.module}/web-server.tpl")}"

  vars = {
    cloud_vendor = "google"
  }
}
