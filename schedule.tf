locals {
  rule = compact(
    concat(
      harness_autostopping_rule_scale_group.this[*].id,
      harness_autostopping_rule_vm.this[*].id,
      harness_autostopping_rule_ecs.this[*].id
    )
  )[0]
}

resource "harness_autostopping_schedule" "this" {
  for_each = var.autostopping_schedules == null ? {} : { for schedule in var.autostopping_schedules : schedule.name => schedule }

  name          = each.value.name
  schedule_type = each.value.type
  time_zone     = each.value.time_zone

  repeats {
    days       = each.value.spec.days
    start_time = each.value.spec.start_time
    end_time   = each.value.spec.end_time
  }

  rules = [local.rule]
}