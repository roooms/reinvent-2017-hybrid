output "0-dns" {
  value = "hybrid-cloud.hashidemos.io"
}

output "aws-dns" {
  value = "${aws_route53_record.hashidemos_aws.fqdn}"
}

output "aws-lb" {
  value = "${module.aws_elb.this_elb_dns_name}"
}

output "gcp-dns" {
  value = "${aws_route53_record.hashidemos_gcp.fqdn}"
}

output "gcp-lb" {
  value = "${google_compute_global_forwarding_rule.default.ip_address}"
}
