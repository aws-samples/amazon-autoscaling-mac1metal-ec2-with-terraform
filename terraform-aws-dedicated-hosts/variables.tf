variable "cf_stack_name" {
  description = "Dedicated host CloudFormation stack name. It can include letters (A-Z and a-z), numbers (0-9), and dashes (-)."
  type        = string
  default     = "host-resource-group"
}

variable "host_resource_group_prefix" {
  description = "Prefix used to create ASG Launch template & Host Resource Group license configuration"
  type        = string
  default     = "mac1-"
}

variable "tags" {
  description = "(Optional) A list of tags to associate with the CloudFormation stack. Does not propagate to the Dedicated Host."
  type        = map(string)
  default     = null
}
