```
module "my_efs" {
  source               = "github.com/simonluijk/tf_efs"
  filesystem_name      = "${var.filesystem_name}"
  account_id           = "${var.account_id}"
  vpc_id               = "${var.vpc_id}"
  vpc_cidr_block       = "${var.vpc_cidr_block}"
  roles                = "${var.roles}"
  subnets              = "${var.subnets}"
  subnets_count        = "${var.subnets_count}"
}
```
