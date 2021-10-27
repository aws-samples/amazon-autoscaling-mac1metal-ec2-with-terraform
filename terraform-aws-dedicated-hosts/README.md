# Terraform AWS Dedicated Host Module

## Usage
TThe code leverages AWS License manager to manage dedicated hosts to overcome Autoscaling limitations.  Before running terraform, the License Manager service role needs to be set up per AWS Documentation 
https://docs.aws.amazon.com/license-manager/latest/userguide/license-manager-role-core.html.  To create the role, it will require IAM CreateRole 
Permissions ("iam:CreateRole"). The link above provides console instructions, or the role can be enabled running the 
following command: 
```
aws iam create-service-linked-role --aws-service-name license-manager.amazonaws.com
```
If successful, a JSON document is returned, and the role is created. 
````
{
    "Role": {
        "Path": "/aws-service-role/license-manager.amazonaws.com/",
        "RoleName": "AWSServiceRoleForAWSLicenseManagerRole",
        "RoleId": "<ROLEID>",
        "Arn": "arn:aws:iam::<ACOUNTID>:role/aws-service-role/license-manager.amazonaws.com/AWSServiceRoleForAWSLicenseManagerRole",
        "CreateDate": "2021-10-27T20:16:57+00:00",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": [
                        "sts:AssumeRole"
                    ],
                    "Effect": "Allow",
                    "Principal": {
                        "Service": [
                            "license-manager.amazonaws.com"
                        ]
                    }
                }
            ]
        }
    }
}
````
If this has already been done,  an error is returned.  
```
An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation: Service role name AWSServiceRoleForAWSLicenseManagerRole has been taken in this account, please try a different suffix.
```
Once this role is set up, the terraform can be used.
```
terraform init
terraform plan
terraform apply -auto-approve
```