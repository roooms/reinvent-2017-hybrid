# re:Invent-2017 Provision Demo

A simple Terraform configuration to demo Terraform Open Source and Terraform Enterprise.

This configuration provisions infrastructure on AWS and Google Cloud to demonstrate the cross-provider functionality Terraform provides.

For AWS: aws.tf uses modules from the [Terraform Module Registry][terraform_registry] to provision a VPC, the necessary networking components and an auto scaling group across multiple AZs. The associated launch configuration launches three instances of the latest Amazon Linux AMI then installs httpd and a custom landing page via a user data script.

For Google: google.tf uses the managed-instance-group module from the Terraform Module Registry to provision a Managed Instance Group in the default VPC and network. The group configuration launches three VMs running CentOS 7 then installs httpd and a custom landing page via a startup script.

## Estimated Time to Complete

20 minutes.

## Prerequisites

### AWS 

* An AWS [key pair][key_pair] is required in the region you are provisioning this infrastructure.
* An AWS Access Key and AWS Secret Access Key should be [configured on the host][cli_config] running this Terraform configuration.

### Google

* A Google credentials file should be present on the host running this Terraform configuration.
* A `GOOGLE_APPLICATION_CREDENTIALS` environment variable should point to the Google credentials file.

> See the ['Getting Started with Authentication'][getting_started_with_gcp] documentation for GCP for guidance

## Steps

1. Copy terraform.tfvars.example to terraform.tfvars:
    
    `cp terraform.tfvars.example terraform.tfvars`

1. For AWS, update the region, and update the ssh_key_name value to a key pair name that pre-exists in the region.
1. For Google, update the project, region and zone you will deploy this infrastructure in.
1. Initialise Terraform to download the required dependencies:

    `terraform init`

1. Execute a plan of the Terraform configuration:

    `terraform plan -out=1.tfplan`

1. Execute an apply of the Terraform configuration:

    `terraform apply 1.tfplan`

### Notes

This configuration uses an AWS auto scaling group and Google Managed Instance Group, both of which launch VMs with ephemeral public DNS/IP addresses. You must check in the AWS and Google consoles or use their respective CLI tools to retrieve the public addresses of each VM.

To destroy the resources provisioned in this example run:

```
terraform plan -out=d.tfplan -destroy
terraform apply d.tfplan
```

[terraform_registry]: https://registry.terraform.io/
[key_pair]: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
[cli_config]: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
[getting_started_with_gcp]: https://cloud.google.com/docs/authentication/getting-started
