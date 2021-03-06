data "aws_route53_zone" "hashidemos" {
  name = "hashidemos.io."
}

# Local resources
resource "aws_route53_record" "hashidemos_gcp" {
  zone_id = "${data.aws_route53_zone.hashidemos.zone_id}"
  name    = "hybrid-cloud-gcp.hashidemos.io."
  type    = "A"
  ttl     = "300"
  records = ["${google_compute_global_forwarding_rule.default.ip_address}"]
}

resource "aws_route53_record" "hashidemos_aws" {
  zone_id = "${data.aws_route53_zone.hashidemos.zone_id}"
  name    = "hybrid-cloud-aws.hashidemos.io."
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.aws_elb.this_elb_dns_name}"]
}

resource "aws_route53_record" "hybrid-cloud-aws" {
  zone_id = "${data.aws_route53_zone.hashidemos.zone_id}"
  name    = "hybrid-cloud.hashidemos.io."
  type    = "CNAME"
  ttl     = "5"

  geolocation_routing_policy {
    continent = "EU"
    country = "*"
  }

  set_identifier = "aws"
  records        = ["hybrid-cloud-aws.hashidemos.io"]
}

resource "aws_route53_record" "hybrid-cloud-gcp" {
  zone_id = "${data.aws_route53_zone.hashidemos.zone_id}"
  name    = "hybrid-cloud.hashidemos.io."
  type    = "CNAME"
  ttl     = "5"

  geolocation_routing_policy {
    country = "*"
  }

  set_identifier = "gcp"
  records        = ["hybrid-cloud-gcp.hashidemos.io"]
}
