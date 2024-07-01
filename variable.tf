variable "projectName" {
  description = "Name of the Project"
  type        = string  
}

variable "project_id" {
  description = "Name of the Project"
  type        = string
  default = "disearchrd"
}

variable "region" {
  description = "Name of the Region"
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "Name of the Location"
  type        = string
  default     = "us-central1-c"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "uscentral-vpc01-100008"
}

variable "vpc_connector" {
  description = "Name of the VPC"
  type        = string
  default     = "disearch-vpc"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "uscentral-disearch-vpc01-subnet1000024"
}

variable "gke_subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "uscentral-disearch-vpc01-subnet1010016-gke"
}

variable "db-instance-name" {
  description = "Prefix for database instance name"
  type        = string
  default     = "disearch-database"
}

variable "db_instance_name_prefix" {
  description = "Prefix for database instance name"
  type        = string
  default     = "disearch-db"
}

variable "db_instance_disk_size" {
  description = "Disk Size for Database Instance"
  type        = string
  default     = "20"
}

variable "db_version" {
  description = "Prefix for database instance name"
  type        = string
  default     = "POSTGRES_14"
}

variable "db_username" {
  description = "Name of the database user"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Password of the database user"
  type        = string
  default     = "M<2ZUQhV8-z^YKt}0OYcBvZ)%.j6N*"
}

variable "cloud_run_service_name" {
  description = "Name of the Cloud Run Service"
  type        = string
  default     = "my-cloud-run-service"
}


variable "gke_cluster_name" {
  description = "Name of the Cluster Name"
  type        = string
  default     = "disearch-cluster"
}

variable "gke_cluster_version" {
  description = "GKE Cluster Version for Master and Workers"
  type        = string
  default     = "1.27.3-gke.100"
}

variable "gke_nodes_machine_type" {
  description = "Instance Type for GKE Worker Nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "gke_minimum_nodes" {
  description = "Minimum Worker Nodes Required for GKE Cluster"
  type        = number
  default     = 6
}

variable "gke_maximum_nodes" {
  description = "Maximum Worker Nodes Required for GKE Cluster"
  type        = number
  default     = 8
}

variable "stackdriver_logging" {
  type    = bool
  default = true

  description = <<EOF
Whether Stackdriver Kubernetes logging is enabled. This should only be set to
"false" if another logging solution is set up.
EOF
}

variable "stackdriver_monitoring" {
  type    = bool
  default = true

  description = <<EOF
Whether Stackdriver Kubernetes monitoring is enabled. This should only be set to
"false" if another monitoring solution is set up.
EOF
}


variable "storage_bucket_name" {
  description = "Name for the Storage Bucket"
  type        = string
  default     = "disearch-storage-bucket"
}

variable "elasticsearch_namespace" {
  description = "Name for the Storage Bucket"
  type        = string
  default     = "elastic-system"
}
