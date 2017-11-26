data "aws_route53_zone" "hashidemos" {
  name = "hashidemos.io."
}

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

  weighted_routing_policy {
    weight = 50
  }

  set_identifier = "aws"
  records        = ["hybrid-cloud-aws.hashidemos.io"]
}

resource "aws_route53_record" "hybrid-cloud-gcp" {
  zone_id = "${data.aws_route53_zone.hashidemos.zone_id}"
  name    = "hybrid-cloud.hashidemos.io."
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 50
  }

  set_identifier = "gcp"
  records        = ["hybrid-cloud-gcp.hashidemos.io"]
}

output "aws-dns" {
  value = "${aws_route53_record.hashidemos_aws.fqdn}"
}

output "gcp-dns" {
  value = "${aws_route53_record.hashidemos_gcp.fqdn}"
}

output "0-dns" {
  value = "hybrid-cloud.hashidemos.io"
}
