terraform {
  required_providers {
    harness = {
      source = "harness/harness"
      # must be at least 0.39.1 for asg support
      version = ">= 0.39.1"
    }
  }
}

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

data "aws_autoscaling_group" "this" {
  name = var.asg_name
}

data "aws_lb_listener" "this" {
  count = var.listener_arn == null ? 0 : 1
  arn   = var.listener_arn
}

data "aws_lb_target_group" "this" {
  count = var.tg_arn == null ? 0 : 1
  arn   = var.tg_arn
}

resource "harness_autostopping_rule_scale_group" "this" {
  name               = var.name
  cloud_connector_id = var.harness_cloud_connector_id
  idle_time_mins     = var.idle_time_mins

  scale_group {
    id        = data.aws_autoscaling_group.this.id
    name      = data.aws_autoscaling_group.this.name
    region    = var.region
    desired   = data.aws_autoscaling_group.this.desired_capacity
    min       = data.aws_autoscaling_group.this.min_size
    max       = data.aws_autoscaling_group.this.max_size
    on_demand = data.aws_autoscaling_group.this.desired_capacity
  }

  dynamic "http" {
    # only create this block if an alb was given
    for_each = harness_autostopping_aws_alb.this
    content {
      proxy_id = harness_autostopping_aws_alb.this[0].identifier
      routing {
        # these are how traffic comes into the alb
        source_protocol = lower(data.aws_lb_target_group.this[0].protocol)
        source_port     = data.aws_lb_listener.this[0].port
        # these are how traffic goes out of the alb to the ec2
        target_protocol = lower(data.aws_lb_target_group.this[0].protocol)
        target_port     = data.aws_lb_target_group.this[0].port
        action          = "forward"
      }
      # this should be configured to match the target group health check
      health {
        protocol         = lower(data.aws_lb_target_group.this[0].health_check[0].protocol)
        port             = data.aws_lb_target_group.this[0].health_check[0].port == "traffic-port" ? data.aws_lb_target_group.this[0].port : data.aws_lb_target_group.this[0].health_check[0].port
        path             = data.aws_lb_target_group.this[0].health_check[0].path
        timeout          = data.aws_lb_target_group.this[0].health_check[0].timeout
        status_code_from = split("-", data.aws_lb_target_group.this[0].health_check[0].matcher)[0]
        status_code_to   = length(split("-", data.aws_lb_target_group.this[0].health_check[0].matcher)) > 1 ? split("-", data.aws_lb_target_group.this[0].health_check[0].matcher)[1] : split("-", data.aws_lb_target_group.this[0].health_check[0].matcher)[0]
      }
    }
  }
  custom_domains = var.alb_arn == null ? [] : [data.aws_lb.this[0].dns_name]
}

resource "harness_autostopping_schedule" "this" {
  count         = var.autostopping_schedules == null || length(var.autostopping_schedules) == 0 ? 0 : 1
  name          = var.schedule_name
  schedule_type = "uptime"
  time_zone     = var.schedule_time_zone

  dynamic "repeats" {
    for_each = var.autostopping_schedules == null ? [] : var.autostopping_schedules
    content {
      days       = repeats.value.days
      start_time = repeats.value.start_time
      end_time   = repeats.value.end_time
    }
  }

  rules = [harness_autostopping_rule_scale_group.this.id]
}
