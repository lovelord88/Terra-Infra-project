variable "name" {
  description = "Prefix used for naming all resources for unique identification."
}

variable "account_name" {
  description = "The name of the AWS account where the code is being deployed"
  default     = "vivienneDotsey"
}

variable "aws_region" {
  description = "The AWS region where the resources will be created."
  default     = "eu-north-1"
}

variable "cname_record_name" {
  description = "The DNS record name to be used for the service, facilitating access via a custom domain name."
}

variable "dns_record_name" {
  description = "The DNS record name to be used for the service, facilitating access via a custom domain name."
}

variable "container_name" {
  description = "The name of the container to be used in task definitions. It acts as a key for linking with the Application Load Balancer."
  default     = "netflix"
}

variable "image" {
  description = "The Docker image to be used for running the service. Format should be repository/image:tag."
  default     = "netflix"
}

variable "app_port" {
  description = "The network port that the Docker container exposes and which will be used by the load balancer to route traffic to the container."
  default     = 80
}

variable "app_count" {
  description = "The desired number of instances of the Docker container to run within the ECS service."
  default     = 2
}

variable "health_check_path" {
  description = "The path used by the load balancer to perform health checks on the Docker container."
  default     = "/"
}

variable "container_cpu" {
  description = "The amount of CPU to allocate for the Fargate task. Specified in CPU units (1 vCPU = 1024 CPU units)."
  default     = 512
}

variable "container_memory" {
  description = "The amount of memory to allocate for the Fargate task, specified in MiB."
  default     = 1024
}

variable "task_cpu" {
  description = "The number of CPU units to allocate for the ECS task."
  type        = string
  default     = 512
}

variable "task_memory" {
  description = "The amount of memory (in MiB) to allocate for the ECS task."
  type        = string
  default     = 1024
}

# VPC Name Variable
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}


# VPC CIDR Variable
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# VPN CIDR Variable
variable "vpn_cidr" {
  description = "CIDR block for the VPN"
  type        = string
}

# Public Subnets Variable
variable "public_subnets" {
  description = "List of public subnets"
  type        = list(any)
}

# Private Subnets Variable
variable "private_subnets" {
  description = "List of private subnets"
  type        = list(any)
}

# Tags Variable
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Region Variable
variable "region" {
  description = "AWS region"
  type        = string
}

# Domain Name Variable
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}