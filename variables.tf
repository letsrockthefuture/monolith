variable "cluster_name" {
  type    = string
  default = "hash-challenge-kubernetes-engine"
}

variable "namespace" {
  type    = string
  default = "monolith"
}

variable "app" {
  type    = string
  default = "monolith"
}

variable "app_version" {
  type    = string
  default = "v1"
}

variable "replicas" {
  type    = number
  default = "1"
}

variable "docker_image" {
  type        = string
  description = "Name of the Docker image to deploy."
  default     = "hashicorp/http-echo:latest"
}

variable "container_port" {
  type    = number
  default = "80"
}
