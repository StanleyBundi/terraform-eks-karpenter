# Defines the deployment name variable as a required string
variable "deployment_name" {
  description = "Name of the deployment"
  type        = string
}

# Specifies the number of replicas, defaulting to 2 if not provided
variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 2
}

# Defines the container image variable as a required string
variable "image" {
  description = "Container image"
  type        = string
}

# Defines the node selector for scheduling pods on specific nodes
variable "node_selector" {
  description = "Node selector for scheduling"
  type        = map(string)
  default     = {}
}
