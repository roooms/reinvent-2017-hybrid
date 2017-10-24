# re:Invent-2017 Provision Demo

A simple Terraform configuration to demo Terraform Open Source and Terraform Enterprise.

The contained configuration uses modules from the Terraform Module Registry to provision a VPC, the necessary networking components and an auto scaling group across multiple AZs. The associated launch configuration launches three instances of the latest Amazon Linux AMI then installs httpd and a custom landing page via a user data script.

## Estimated Time to Complete

15 minutes.

## Prerequisites
* An AWS [key pair][key_pair] is required in the region you are provisioning this infrastructure.
* An AWS Access Key and AWS Secret Access Key should be [configured on the host][cli_config] running this Terraform configuration.

## Steps

1. Copy terraform.tfvars.example to terraform.tfvars:
    
    `cp terraform.tfvars.example terraform.tfvars`

1. Update the region you will deploy this infrastructure in.
1. Update the ssh_key_name value to a key pair name that pre-exists in the region.
1. Initialise Terraform to download the required dependencies:

    `terraform init`

1. Execute a plan of the Terraform configuration:

    `terraform plan -out=1.tfplan`

1. Execute an apply of the Terraform configuration:

    `terraform apply 1.tfplan`

### Notes

This configuration uses an auto scaling group to launch three instances so you must check in the AWS console or use the AWS CLI tools to retrieve the public DNS addresses of each instance.

To destroy the resources provisioned in this example run:

```
terraform plan -out=d.tfplan -destroy
terraform apply d.tfplan
```

[key_pair]: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
[cli_config]: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
