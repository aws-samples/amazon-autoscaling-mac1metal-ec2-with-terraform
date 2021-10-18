output "mac_ami" {
    description = "AMI Id from SSM Parameter Store"
    value = data.aws_ssm_parameter.mac_ami.value
}

output "host_resource_group_arn" {
    # todo: update this to use tf aws provider resourcegroup query output
    #host_resource_group_arn = aws_cloudformation_stack.mac_workers_resource_group.outputs["ResourceGroupId"]
    description = "Resource Group ARN"
    value = data.aws_resourcegroupstaggingapi_resources.resourcegroup.resource_arn_list
}
