provider "google" {
  project = "${var.google_project}"
  region  = "${var.google_region}"
}

# Use module registry: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.0.2
module "gcp_mig" {
  source            = "GoogleCloudPlatform/managed-instance-group/google"
  version           = "1.0.2"
  region            = "${var.google_region}"
  zone              = "${var.google_zone}"
  network           = "default"
  name              = "web-server"
  machine_type      = "f1-micro"
  compute_image     = "centos-cloud/centos-7"
  size              = 3
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.web_server_google.rendered}"
  target_tags       = ["allow-service", "http-server"]
}

# Use module registry: https://registry.terraform.io/modules/GoogleCloudPlatform/lb-http/google/1.0.4
module "gcp_lb_http" {
  source      = "GoogleCloudPlatform/lb-http/google"
  version     = "1.0.4"
  name        = "group-http-lb"
  target_tags = ["${module.gcp_mig.target_tags}"]
  network     = "default"

  backends = {
    "0" = [{
      group = "${module.gcp_mig.instance_group}"
    }]
  }

  backend_params = [
    # health check path, port name, port number, timeout seconds
    "/,http,80,5",
  ]
}

# Data sources
data "template_file" "web_server_google" {
  template = "${file("${path.module}/web-server.tpl")}"
}

# Outputs
output "gcp-lb" {
  value = "${module.gcp_lb_http.external_ip}"
}
