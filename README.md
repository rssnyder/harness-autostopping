# harness-autostopping

this module will create autostopping components for the target resource type, any combination of traffic, schedule, or none

## asg

autostopping for aws autoscaling groups

### required inputs

- asg_name
- idle_time_mins
- harness_cloud_connector_id
- region

### optional inputs

#### schedules

- autostopping_schedules: list of uptime schedules repeat windows
- schedule_name: optional name for the schedule
- schedule_time_zone: optional timezone for the schedule

#### traffic

- vpc_id: vpc id
- alb_arn: id of the alb to import to harness
- listener_arn: listener arn
- tg_arn: target group arn

## ec2

autostopping for aws ec2 instances

### required inputs

- ec2_id
- idle_time_mins
- harness_cloud_connector_id
- region

### optional inputs

#### schedules

- autostopping_schedules: list of uptime schedules repeat windows
- schedule_name: optional name for the schedule
- schedule_time_zone: optional timezone for the schedule

#### traffic

- vpc_id: vpc id
- alb_arn: id of the alb to import to harness
- listener_arn: listener arn
- tg_arn: target group arn

# module spec

## Requirements

| Name | Version |
|------|---------|
| harness | >= 0.39.1 |

## Providers

| Name | Version |
|------|---------|
| aws | 6.26.0 |
| harness | 0.39.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [harness_autostopping_aws_alb.this](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/autostopping_aws_alb) | resource |
| [harness_autostopping_rule_scale_group.this](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/autostopping_rule_scale_group) | resource |
| [harness_autostopping_schedule.this](https://registry.terraform.io/providers/harness/harness/latest/docs/resources/autostopping_schedule) | resource |
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/autoscaling_group) | data source |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb_listener) | data source |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb_target_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alb\_arn | id of the alb to import to harness; set to enable alb autostopping | `string` | `null` | no |
| asg\_name | asg id | `string` | n/a | yes |
| autostopping\_schedules | Optional list of schedule repeat windows. If null, no Harness autostopping schedule will be created. | <pre>list(object({<br/>    days       = list(string)<br/>    start_time = string<br/>    end_time   = string<br/>  }))</pre> | `null` | no |
| harness\_cloud\_connector\_id | harness cloud connector id | `string` | n/a | yes |
| idle\_time\_mins | idle time | `number` | n/a | yes |
| listener\_arn | listener arn; required if alb\_arn set | `string` | `null` | no |
| name | name for this alb/rule | `string` | n/a | yes |
| region | cloud region | `string` | n/a | yes |
| schedule\_name | Name for the schedule | `string` | `"this"` | no |
| schedule\_time\_zone | Timezone for uptime schedule | `string` | `"America/Chicago"` | no |
| tg\_arn | target group arn; required if alb\_arn set | `string` | `null` | no |
| vpc\_id | vpc id; required if alb\_arn set | `string` | `null` | no |

## Outputs

No outputs.