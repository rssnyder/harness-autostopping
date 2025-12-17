data "aws_lb" "this" {
  count = var.alb_arn == null ? 0 : 1
  arn   = var.alb_arn
}

resource "harness_autostopping_aws_alb" "this" {
  count                             = var.alb_arn == null ? 0 : 1
  name                              = data.aws_lb.this[0].name
  cloud_connector_id                = var.harness_cloud_connector_id
  host_name                         = local.lb_hostname
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

  dynamic "scale_group" {
    # only create this block if an alb was given
    for_each = harness_autostopping_aws_alb.this
    content {
      id        = data.aws_autoscaling_group.this.id
      name      = data.aws_autoscaling_group.this.name
      region    = var.region
      desired   = data.aws_autoscaling_group.this.desired_capacity
      min       = data.aws_autoscaling_group.this.min_size
      max       = data.aws_autoscaling_group.this.max_size
      on_demand = data.aws_autoscaling_group.this.desired_capacity
    }
  }

  dynamic "http" {
    # only create this block if an alb was given
    for_each = harness_autostopping_aws_alb.this
    content {
      proxy_id = https.identifier
      routing {
        # these are how traffic comes into the alb
        source_protocol = lower(data.aws_lb_target_group.this.protocol)
        source_port     = data.aws_lb_listener.this.port
        # these are how traffic goes out of the alb to the ec2
        target_protocol = lower(data.aws_lb_target_group.this.protocol)
        target_port     = data.aws_lb_target_group.this.port
        action          = "forward"
      }
      # this should be configured to match the target group health check
      health {
        protocol         = lower(data.aws_lb_target_group.this.health_check.protocol)
        port             = data.aws_lb_target_group.this.health_check.port
        path             = data.aws_lb_target_group.this.health_check.path
        timeout          = data.aws_lb_target_group.this.health_check.timeout
        status_code_from = split("-", data.aws_lb_target_group.this.health_check.matcher)[0]
        status_code_to   = split("-", data.aws_lb_target_group.this.health_check.matcher)[1]
      }
    }
  }
  custom_domains = [data.aws_lb.this[0].dns_name]
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

  rules = [harness_autostopping_rule_scale_group.rule.id]
}