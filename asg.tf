data "aws_autoscaling_group" "this" {
  count = var.asg_name == null ? 0 : 1
  name  = var.asg_name
}

resource "harness_autostopping_rule_scale_group" "this" {
  count              = var.asg_name == null ? 0 : 1
  name               = var.name
  cloud_connector_id = var.harness_cloud_connector_id
  idle_time_mins     = var.idle_time_mins

  scale_group {
    id        = data.aws_autoscaling_group.this[0].id
    name      = data.aws_autoscaling_group.this[0].name
    region    = var.region
    desired   = data.aws_autoscaling_group.this[0].desired_capacity
    min       = 0
    max       = data.aws_autoscaling_group.this[0].max_size
    on_demand = data.aws_autoscaling_group.this[0].desired_capacity
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

  lifecycle {
    ignore_changes = [
      scale_group[0].desired,
      scale_group[0].on_demand,
    ]
  }

}