###
# Default Variables
###
# variable "environment" {
#   description = "The Environment that this module will be built in e.g. dev/test/prod"
#   type        = string
#   default     = "dev"
# }

# variable "termination_protection" {
#   description = "Will this infrastructure be protected by Termination Protection or will it be allowed to be destroyed by Terraform runs?"
#   type        = bool
#   default     = false
# }

# variable "account_id" {
#   description = "The ID of the AWS Account the module will be built in"
#   type        = string
# }

# variable "account_code" {
#   description = "The Colour code of the AWS Account that the module will be built in e.g. blue/red/green"
#   type        = string
# }

# variable "pci" {
#   description = "Is the module being built in a PCI account?"
#   type        = bool
#   default     = false
# }

# variable "hse" {
#   description = "Is the module being built in a High Security Environment?"
#   type        = bool
#   default     = false
# }

# variable "bz_ingress" {
#   description = "Is the module being built in an account that has Corp ingress?"
#   type        = bool
#   default     = false
# }

###
# Module Specific vars
###
variable "region" {
  description = "The Region that we will be building the module in"
  type        = string
}

variable "name" {
  description = "If specified, will set the name of the module to this. If unspecified, a name will be generated"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "EC2: The user data to provide when launching the instance"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "SSM Parameter used to lookup the latest EC2 Mac1 AMI"
  type = string
  default = "ami-00703177f48697c84"
}

variable "host_resource_group_cfn_stack_name" {
  description = "Host Resource Group CFN Stack Created"
  type = string
  default = "mac1-host-resource-group-famous-anchovy"
}

variable "number_of_instances" {
  description = "Desired Capacity of EC2 Mac1 instances in ASG"
  type        = number
  default     = 2
}

variable "min_num_instances" {
  description = "Min number of EC2 Mac1 instances in ASG"
  type        = number
  default     = 1
}

variable "max_num_instances" {
  description = "Max number of EC2 Mac1 instances in ASG"
  type        = number
  default     = 3
}

variable "vpc_id" {
  description = "VPC Id for LB Target Group"
  type = string
  default = ""
}

variable "subnet_ids" {
  description = "Subnet Id for each Availability Zone in ASG"
  type        = list(string)
  # Launching a new EC2 instance. (wrt us-east-2a)
  # Status Reason: We currently do not have sufficient mac1.metal capacity in the Availability Zone you requested (us-east-2a). 
  # Our system will be working on provisioning additional capacity. 
  # You can currently get mac1.metal capacity by specifying us-east-2b, us-east-2c in your request. 
  # Launching EC2 instance failed.
  #default     = ["subnet-02fa49fed58e844eb","subnet-08ca30a8af336beee"] # public subnets
  default = [] # testing in us-east-2b / 
}

variable "security_group_ids" {
  description = "Security Group Ids used by EC2 Mac1 instances in ASG"
  type        = list(string)
  default     = ["sg-0d0c462ff917f04e0"]
}

variable "mac_ebs_volume_size" {
  description = "EC2 Mac1 EBS volume size"
  type        = number
  default     = 100
}

variable "worker_prefix" {
  description = "Prefix used to create ASG Launch template & Host Resource Group license configuration"
  type        = string
  default     = "ec2"
}

variable "tags" {
  description = "(Optional) A list of tags to associate with the CloudFormation stack. Does not propagate to the Dedicated Host."
  type        = map(string)
  default     = null
}

variable "management_subnet" {
  description = "Allow access from management subnet"
  type = list(string)
  default = []
}

variable "key_name" {
  description = "SSH key"
  type = string
  default = ""
}

variable "license_manager_arn" {
  description = "The ARN of the License Configuration named MyDefaultLicense"
  type = string
  default = ""
}
