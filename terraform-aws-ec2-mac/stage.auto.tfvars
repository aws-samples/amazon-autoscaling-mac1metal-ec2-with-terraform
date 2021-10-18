instance_type     = "mac1.metal"
availability_zone = "us-west-2a"
region = "us-east-2"
vpc_id = "vpc-xyz"
subnet_ids = [ "subnet-xyz", "subnet-wxyz", "subnet-abcd" ]  # public subnets
security_group_ids = ["sg-abcd"]
host_resource_group_cfn_stack_name = "mac1-host-resource-group-casual-coral"
