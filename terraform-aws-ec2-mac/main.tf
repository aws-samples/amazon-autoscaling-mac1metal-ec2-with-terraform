resource "random_pet" "mac_workers" {
  length    = 2
  prefix    = var.worker_prefix
  separator = "-"
}


# Generate a random string to add it to the name of the Target Group
resource "random_string" "str_prefix" {
  length  = 4
  upper   = false
  special = false
}

data "aws_cloudformation_export" "host_resource_group_arn" {
  name = var.host_resource_group_cfn_stack_name
}

resource "aws_licensemanager_license_configuration" "mac_workers" {
  name = random_pet.mac_workers.id

  license_count = 1000
  license_count_hard_limit = false
  #license_counting_type = "Instance" # This option fails to launch ec2 mac instance onto dedicated host
  license_counting_type = "Core"

  tags = {
      CreationTimestamp = timestamp() 
      Name              = join("-", [random_pet.mac_workers.id, "lm"])
      Terraform         = random_pet.mac_workers.id
  }

  # ignore on tag changes
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "aws_iam_instance_profile" "ssm_inst_profile" {
  name = "ec2_role_${random_pet.mac_workers.id}"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role_${random_pet.mac_workers.id}"
  path = "/"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": {
      "Sid": "AllowSSMSesionManager"
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  })
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm_role_${random_pet.mac_workers.id}"
  path = "/"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": {
      "Sid": "AllowSSMSesionManager"
      "Effect": "Allow",
      "Principal": {"Service": "ssm.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  })
}

locals {
  instance_role_managed_policies = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role       = aws_iam_role.ec2_role.name
  count      = length(local.instance_role_managed_policies)
  policy_arn = local.instance_role_managed_policies[count.index]
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_ssm_activation" "ssm_attach" {
  name               = "ssm_activation"
  description        = "Activate SSM on EC2"
  iam_role           = aws_iam_role.ssm_role.id
  registration_limit = "5"
  depends_on         = [aws_iam_role_policy_attachment.ssm_attach]
}

data "aws_ami" "mac" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn-ec2-macos-10.15*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

resource "aws_launch_template" "mac_workers" {
  name = random_pet.mac_workers.id
  #Can specify the ami in var
  #image_id      = var.ami_id
  #Or get the AMI use version
  image_id           = data.aws_ami.mac.id
  instance_type = "mac1.metal"

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_inst_profile.name
  }
  
  # Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
  #leverage Variables to list security groups
  #vpc_security_group_ids = slice(var.security_group_ids, 0, length(var.security_group_ids)) # Security Group IDs for ASG in non-default vpc
  #use terraform code to create security groups
  vpc_security_group_ids = [aws_security_group.apple_remote_desktop.id]

  # module.web_server_sg.security_group_id
  #vpc_security_group_ids = slice(module.web_server_sg.security_group_id, 0, length(module.web_server_sg.security_group_id))

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = "true"
      volume_size           = var.mac_ebs_volume_size
      volume_type           = "gp3"
    }
  }

  license_specification {
    # One or more licenses need to be specified for a valid Server Manageability call. Launching EC2 Mac1 requires RG+LM
    license_configuration_arn = var.license_manager_arn
  }

  placement {
    tenancy                 = "host"
    host_resource_group_arn = data.aws_cloudformation_export.host_resource_group_arn.value
  }


  # Instance Resource Tags
  tag_specifications {
    resource_type = "instance"
    tags = {
      CreationTimestamp = timestamp() 
      Name              = join("-", [random_pet.mac_workers.id, "node"])
      Terraform         = random_pet.mac_workers.id
    }
  }

  # Launch Template Resource Tags
  tags = {
    Name              = join("-", [random_pet.mac_workers.id, "lt"])
    Terraform         = random_pet.mac_workers.id
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
      latest_version,
      tag_specifications,
      #user_data,          # toggle this to ignore user data updates
      #image_id,           # toggle this when to ignore image id updates
    ]
  }
}


resource "aws_autoscaling_group" "mac_workers" {
  name = random_pet.mac_workers.id

  # Testing: Toggle between EC2 & ELB Health Checks as needed
  health_check_type = "EC2"
  health_check_grace_period = 300
  # Enable ELB health checks - note: uncomment when sample app running at launch
  # health_check_type = "ELB"
  # health_check_grace_period = 300 # time before first health check

  # Desired Capacity
  desired_capacity   = var.number_of_instances
  max_size           = var.max_num_instances
  min_size           = var.min_num_instances

  # ASG Metrics Enabled
  metrics_granularity = "1Minute"
  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = aws_launch_template.mac_workers.id
    version = "$Latest"
  }

  # VPCZoneIdentifier
  # Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
  vpc_zone_identifier = slice(var.subnet_ids, 0, length(var.subnet_ids))

  # Setting this because this ASG is unable to launch working instances
  #wait_for_capacity_timeout = 0

  # Optional: Warm Pool of Dedicated Hosts & EC2 Mac1 Instances
  # warm_pool {
  #   pool_state  = "Stopped"
  #   min_size    = 1
  #   max_group_prepared_capacity = 2
  # }

  # Auto-Scaling Group Resource Tags
  tags = concat(
    [
      {
        key                 = "Name"
        value               = join("-", [random_pet.mac_workers.id, "node"])
        propagate_at_launch = true
      },
      {
        key                 = "Terraform"
        value               = random_pet.mac_workers.id
        propagate_at_launch = true
      } 
    ]
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      launch_template,
      #desired_capacity,  # toggle to reset desired capacity if testing auto-scaling
      target_group_arns,
      load_balancers,
    ]
  }

  timeouts {
    delete = "15m"
  }
}

# AWS ALB ASG Attachment (alternative is inline ASG resource)
# Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment
#resource "aws_autoscaling_attachment" "mac_workers" {
#  autoscaling_group_name = aws_autoscaling_group.mac_workers.id
#  alb_target_group_arn   = aws_lb_target_group.app_tg.arn
#}

## Auto-Scaling Policy based on CloudWatch Metric CPUUtilization
resource "aws_autoscaling_policy" "mac_workers" {
  name                   = "${random_string.str_prefix.result}-sampleapp-test"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.mac_workers.name

  # Scaling Policy
  # Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy
  # policy_type        = "SimpleScaling"
  # scaling_adjustment = 2
  # cooldown           = 30
  # policy_type = "StepScaling"
  # step_adjustment {
  #   scaling_adjustment          = -1
  #   metric_interval_lower_bound = 5
  #   metric_interval_upper_bound = 10
  # }

  # step_adjustment {
  #   scaling_adjustment          = 1
  #   metric_interval_lower_bound = 20
  #   metric_interval_upper_bound = 40
  # }

  # step_adjustment {
  #   scaling_adjustment          = 2
  #   metric_interval_lower_bound = 60
  # }

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value      = 10.0
    disable_scale_in  = false # false by default so will change asg desired_capacity
  }

  # target_tracking_configuration {
  #   customized_metric_specification {
  #     metric_dimension {
  #       name  = "fuga"
  #       value = "fuga"
  #     }

  #     metric_name = "hoge"
  #     namespace   = "hoge"
  #     statistic   = "Average"
  #   }

  #   target_value = 40.0
  # }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      adjustment_type,
    ]
  }
}

resource "aws_security_group" "apple_remote_desktop" {
  name        = "sg_apple_remote_desktop"
  description = "Allow Apple Desktop Traffic"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description = "SSH over 22"
      from_port   = 0
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.management_subnet
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    },
    {
      description = "VNC for ARD"
      from_port   = 0
      to_port     = 5900
      protocol    = "tcp"
      cidr_blocks = var.management_subnet
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  egress = [
    {
      description      = "Allow all outbound traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]

  tags = {
    Name = "remote desktop connection"
  }
}