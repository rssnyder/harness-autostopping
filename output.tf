output "autostopping_rule_id" {
  value = local.rule
}

output "autostopping_schedule_ids" {
  value = [for schedule in harness_autostopping_schedule.this : schedule.id]
}