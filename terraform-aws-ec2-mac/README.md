# terraform-aws-ec2-mac

## Usage

Currently whitelisted for isengard accounts
```
export AWS_REGION="us-east-2"
```

The output off module `terraform-aws-dedicated-hosts` here as variable:
```
terraform init
terraform plan -var host_resource_group_cfn_stack_name="mac1-host-resource-group-casual-coral"
terraform apply -var host_resource_group_cfn_stack_name="mac1-host-resource-group-casual-coral" -auto-approve
```