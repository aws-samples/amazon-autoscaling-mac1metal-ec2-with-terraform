resource "random_pet" "host_resource_group" {
  length    = 2
  prefix    = join("", [var.host_resource_group_prefix, var.cf_stack_name])
  separator = "-"
}
resource "aws_cloudformation_stack" "mac1_host_resource_group" {
  name = random_pet.host_resource_group.id
  #tags = var.tags

  template_body = <<STACK
{
    "Resources" : {
        "HostResourceGroup": {
            "Type": "AWS::ResourceGroups::Group",
            "Properties": {
                "Name": "${random_pet.host_resource_group.id}",
                "Configuration": [
                    {
                        "Type": "AWS::EC2::HostManagement",
                        "Parameters": [
                            {
                                "Name": "any-host-based-license-configuration",
                                "Values": [
                                    "true"
                                ]
                            },
                            {
                                "Name": "allowed-host-families",
                                "Values": [
                                    "mac1"
                                ]
                            },
                            {
                                "Name": "auto-allocate-host",
                                "Values": [
                                    "true"
                                ]
                            },
                            {
                                "Name": "auto-release-host",
                                "Values": [
                                    "true"
                                ]
                            }
                        ]
                    },
                    {
                        "Type": "AWS::ResourceGroups::Generic",
                        "Parameters": [
                            {
                                "Name": "allowed-resource-types",
                                "Values": [
                                    "AWS::EC2::Host"
                                ]
                            },
                            {
                                "Name": "deletion-protection",
                                "Values": [
                                    "UNLESS_EMPTY"
                                ]
                            }
                        ]
                    }
                ]
            }
        }
    },
    "Outputs" : {
        "ResourceGroupArn" : {
            "Description": "ResourceGroup Arn",
            "Value" : { "Fn::GetAtt" : ["HostResourceGroup", "Arn"] },
            "Export" : {
              "Name": "${random_pet.host_resource_group.id}"
            }
        }
    }
}
STACK
}
