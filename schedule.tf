locals {
  rules = compact(
    concat(
      harness_autostopping_rule_scale_group.this[*].id,
      harness_autostopping_rule_vm.this[*].id,
      harness_autostopping_rule_ecs.this[*].id
    )
  )
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

  rules = local.rules
}