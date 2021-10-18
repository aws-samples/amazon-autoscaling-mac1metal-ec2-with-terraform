# terraform-aws-ec2-mac
Terraform - AWS EC2 Module to setup EC2 Mac instances.

## Status (WiP)
Radar Sprint Tracking -> rdar://81582029

| Pipeline | Publish |
| -------- | ----- |
| `create-release` | [![loading...][2]][1] |

[1]: https://rio.apple.com/projects/applepay-aws-terraform-aws-ec2-mac
[2]: https://badges.pie.apple.com/badges/rio?p=applepay-aws-terraform-aws-ec2-mac&s=applepay-aws-terraform-aws-ec2-mac-create-release-main-publish

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.taliesin_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_ami.mac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [template_cloudinit_config.config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |
| [template_file.pci](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_number_of_instances"></a> [number\_of\_instances](#input\_number\_of\_instances) | Number of EC2 mac instances to provision | `number` | `2` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | EC2: The user data to provide when launching the instance | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mac_ami"></a> [mac\_ami](#output\_mac\_ami) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
