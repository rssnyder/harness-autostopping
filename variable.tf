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

# ALB
variable "vpc_id" {
  type        = string
  description = "vpc id; required if alb_arn set"
  default     = null
}

variable "alb_arn" {
  type        = string
  description = "id of the alb to import to harness; set to enable alb autostopping"
  default     = null
}

# Listener
variable "listener_arn" {
  type        = string
  description = "listener arn; required if alb_arn set, unless using ecs"
  default     = null
}

# TG
variable "tg_arn" {
  type        = string
  description = "target group arn; required if alb_arn set, unless using ecs"
  default     = null
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

# ASG
variable "asg_name" {
  type        = string
  description = "asg id"
  default     = null
}

# EC2

variable "ec2_id" {
  type        = string
  description = "ec2 id"
  default     = null
}

# ECS

variable "ecs_service_name" {
  type        = string
  description = "ecs service name"
  default     = null
}

variable "ecs_cluster_name" {
  type        = string
  description = "ecs cluster name; required if ecs_service_name set"
  default     = null
}
