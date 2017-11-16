provider "google" {
  project = "${var.google_project}"
  region  = "${var.google_region}"
}

# Use module registry: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.0.2
module "gcp_mig1" {
  source            = "GoogleCloudPlatform/managed-instance-group/google"
  region            = "${var.google_region}"
  zone              = "${var.google_zone}"
  network           = "default"
  name              = "${var.configuration_name}-group1"
  machine_type      = "f1-micro"
  compute_image     = "centos-cloud/centos-7"
  size              = 2
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.web_server_google.rendered}"
  target_tags       = ["allow-service", "http-server"]
}

# Use module registry: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.0.2
module "gcp_mig2" {
  source            = "GoogleCloudPlatform/managed-instance-group/google"
  region            = "${var.google_region}"
  zone              = "${var.google_zone}"
  network           = "default"
  name              = "${var.configuration_name}-group2"
  machine_type      = "f1-micro"
  compute_image     = "centos-cloud/centos-7"
  size              = 2
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.web_server_google.rendered}"
  target_tags       = ["allow-service", "http-server"]
}

# Use module registry: https://registry.terraform.io/modules/GoogleCloudPlatform/lb-http/google/1.0.4
module "gcp_lb_http" {
  source      = "GoogleCloudPlatform/lb-http/google"
  name        = "group-http-lb"
  target_tags = ["${module.gcp_mig1.target_tags}", "${module.gcp_mig2.target_tags}"]
  network     = "default"

  backends = {
    "0" = [
      {
        group = "${module.gcp_mig1.instance_group}"
      },
      {
        group = "${module.gcp_mig2.instance_group}"
      },
    ]
  }

  backend_params = [
    # health check path, port name, port number, timeout seconds
    "/,http,80,10",
  ]
}

# Data sources
data "template_file" "web_server_google" {
  template = "${file("${path.module}/web-server.tpl")}"

  vars = {
    cloud_vendor = "google"
  }
}

# Outputs
output "gcp-lb" {
  value = "${module.gcp_lb_http.external_ip}"
}