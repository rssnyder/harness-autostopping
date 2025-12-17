variable "name" {
  type        = string
  description = "name for this alb/rule"
}

# Harness
variable "harness_cloud_connector_id" {
  type        = string
  description = "harness cloud connector id"
}

variable "idle_time_mins" {
  type        = number
  description = "idle time"
}

# AWS
variable "region" {
  type        = string
  description = "cloud region"
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
}

# ALB
variable "alb_arn" {
  type        = string
  description = "id of the alb to import to harness; set to enable alb autostopping"
  default     = null
}

# Listener
variable "listener_arn" {
  type        = string
  description = "listener arn; required if alb_arn set"
  default     = null
}

# TG
variable "tg_arn" {
  type        = string
  description = "target group arn; required if alb_arn set"
  default     = null
}

# ASG
variable "asg_name" {
  type        = string
  description = "asg id"
}

# Schedule
variable "schedule_name" {
  type        = string
  description = "Name for the schedule"
  default     = "this"
}

variable "autostopping_schedules" {
  type = list(object({
    days       = list(string)
    start_time = string
    end_time   = string
  }))
  default     = null
  description = "Optional list of schedule repeat windows. If null, no Harness autostopping schedule will be created."
}

variable "schedule_time_zone" {
  type        = string
  description = "Timezone for uptime schedule"
  default     = "America/Chicago"
}