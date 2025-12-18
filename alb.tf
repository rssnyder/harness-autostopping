data "aws_lb" "this" {
  count = var.alb_arn == null ? 0 : 1
  arn   = var.alb_arn
}

resource "harness_autostopping_aws_alb" "this" {
  count                             = var.alb_arn == null ? 0 : 1
  name                              = data.aws_lb.this[0].name
  cloud_connector_id                = var.harness_cloud_connector_id
  host_name                         = data.aws_lb.this[0].dns_name
  alb_arn                           = data.aws_lb.this[0].arn
  region                            = var.region
  vpc                               = var.vpc_id
  security_groups                   = data.aws_lb.this[0].security_groups
  delete_cloud_resources_on_destroy = false
}

data "aws_lb_listener" "this" {
  count = var.listener_arn == null ? 0 : 1
  arn   = var.listener_arn
}

data "aws_lb_target_group" "this" {
  count = var.tg_arn == null ? 0 : 1
  arn   = var.tg_arn
}