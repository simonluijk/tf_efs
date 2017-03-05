variable "account_id" {}
variable "vpc_id" {}
variable "vpc_cidr_block" {}

# Roles that will be given access to EFS filesystem
variable "roles" {}

# Subnets where EFS mount targets will be created
variable "subnets" {}
variable "subnets_count" {}
variable "filesystem_name" {}

resource "aws_iam_policy" "efs_policy" {
  name = "EFS-${var.filesystem_name}-Access-Policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1PermissionForAllEFSActions",
      "Effect": "Allow",
      "Action": "elasticfilesystem:*",
      "Resource": "arn:aws:elasticfilesystem:us-west-2:${var.account_id}:file-system/${var.filesystem_name}"
    },
    {
      "Sid": "Stmt2RequiredEC2PermissionsForAllEFSActions",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeSubnets",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:DescribeNetworkInterfaceAttribute"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs_efs_attachment" {
    name = "EFS-${var.filesystem_name}-PolicyAttachment"
    roles = ["${split(",", var.roles)}"]
    policy_arn = "${aws_iam_policy.efs_policy.arn}"
}

resource "aws_security_group" "efs" {
    vpc_id = "${var.vpc_id}"
    name = "EFS ${var.filesystem_name} SG"
    description = "EFS ${var.filesystem_name} allowed traffic"

    # NFS
    ingress {
        protocol = "tcp"
        from_port = 2049
        to_port = 2049
        cidr_blocks = ["${var.vpc_cidr_block}"]
    }

    tags {
        Name = "EFS ${var.filesystem_name} SG"
    }
}

resource "aws_efs_file_system" "shared_ecs" {
    creation_token = "${var.filesystem_name}"
    tags {
        Name = "${var.filesystem_name}"
    }
}

resource "aws_efs_mount_target" "shared_ecs_mount" {
    /*
    count = "${length(var.subnets)}"
    Currently not allowed on computed variables.
    */
    count = "${var.subnets_count}"
    file_system_id = "${aws_efs_file_system.shared_ecs.id}"
    subnet_id = "${element(split(",", var.subnets), count.index)}"
    security_groups = ["${aws_security_group.efs.id}"]
}

output "security_group" {
    value = "${aws_security_group.efs.id}"
}
