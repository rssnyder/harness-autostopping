data "aws_instance" "this" {
  count       = var.ec2_id == null ? 0 : 1
  instance_id = var.ec2_id
}

resource "harness_autostopping_rule_vm" "this" {
  count              = var.ec2_id == null ? 0 : 1
  name               = var.name
  cloud_connector_id = var.harness_cloud_connector_id
  idle_time_mins     = var.idle_time_mins

  filter {
    vm_ids  = [data.aws_instance.this[0].id]
    regions = [var.region]
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