data "aws_ecs_cluster" "this" {
  count        = var.ecs_service_name == null ? 0 : 1
  cluster_name = var.ecs_cluster_name
}

data "aws_ecs_service" "this" {
  count        = var.ecs_service_name == null ? 0 : 1
  service_name = var.ecs_service_name
  cluster_arn  = data.aws_ecs_cluster.this[0].arn
}

resource "harness_autostopping_rule_ecs" "this" {
  count              = var.ecs_service_name == null ? 0 : 1
  name               = var.name
  cloud_connector_id = var.harness_cloud_connector_id
  idle_time_mins     = var.idle_time_mins

  container {
    cluster    = data.aws_ecs_cluster.this[0].cluster_name
    service    = data.aws_ecs_service.this[0].service_name
    region     = var.region
    task_count = data.aws_ecs_service.this[0].desired_count
  }

  dynamic "http" {
    # only create this block if an alb was given
    for_each = harness_autostopping_aws_alb.this
    content {
      proxy_id = harness_autostopping_aws_alb.this[0].identifier
    }
  }

  custom_domains = var.alb_arn == null ? [] : [data.aws_lb.this[0].dns_name]
}
