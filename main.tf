terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.82.0"
    }
    kubernetes = {
      source  = "hashicorp/helm"
      version = "2.11.0"
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.14.0"
    }
  }
}



provider "google" {
  project     = var.projectName
  region      = var.region
  credentials = file("/creds/${var.projectName}/secret.json")
}

provider "kubernetes" {
  config_path = "~/.kube/config"
 }


provider "kubectl" {
  config_path = "~/.kube/config"
}












//SERVICESSS START HERE

resource "google_project_service" "enable_cloudbuild" {
  project = var.projectName
  service = "cloudbuild.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "enable_containerregistry" {
  project = var.projectName
  service = "containerregistry.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "enable_secretmanager" {
  project = var.projectName
  service = "secretmanager.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "enable_naturallanguage" {
  project = var.projectName
  service = "language.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "enable_servicenetworking" {
  project = var.projectName
  service = "servicenetworking.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "enable_sqladmin" {
  project = var.projectName
  service = "sqladmin.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "enable_run" {
  project = var.projectName
  service = "run.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "enable_cloudresourcemanager" {
  project = var.projectName
  service = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "enable_iamcredentials" {
  project = var.projectName
  service = "iamcredentials.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "disable_all_services" {
  project = var.projectName
  service = "iam.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
  
}

resource "google_project_service" "enable_container" {
  project = var.projectName
  service = "container.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "enable_documentai" {
  project = var.projectName
  service = "documentai.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}


resource "google_project_service" "storage_api" {
  project = var.projectName
  service = "storage-api.googleapis.com"  # Adjust the API service name
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  project = var.projectName
  service            = "storage-component.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "enable_compute" {
  service = "compute.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "enable_vpcaccess" {
  project = var.projectName
  service = "vpcaccess.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "service_usage" {
  service = "serviceusage.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "secret_manager_api" {
  service = "secretmanager.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}


//SERVICES ENDS HERE-------------------------------------------------













//VPC STARTS HEREE---------------------------------------------------

//resource "google_compute_network" "peering_network" {
//  name                    = "private-network"
//  auto_create_subnetworks = "false"
//}

resource "google_compute_global_address" "peering_address" {
  name        = "google-managed-services-default"
  # description = "peering range for Google"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "default"
}

resource "google_service_networking_connection" "peering_connection" {
  network                 = "default"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.peering_address.name]
  depends_on = [ google_compute_global_address.peering_address ]
}

resource "google_vpc_access_connector" "disearch_vpc_connector" {
  name    = "disearch-vpc-connector"
  project = var.projectName
  region  = var.region
  network = "default"
  ip_cidr_range  = "10.10.10.0/28"
  min_instances = 2
  max_instances = 4
  machine_type = "e2-micro"
  max_throughput = 500
  lifecycle {
    ignore_changes = [
      network,
      max_throughput,
      id,
    ]
  }
  depends_on = [ google_service_networking_connection.peering_connection ]
}



//VPC ENDS HERE ------------------------------------------------------------------

















//SUBNETS STARTS HEREEEE ----------------------------------------------------------



resource "google_compute_subnetwork" "uscentral_disearch_vpc01_subnet1000024" {
  name          = var.subnet_name
  ip_cidr_range = "10.0.0.0/24"
  network       = "default"
  region        = var.region
  private_ip_google_access = true
  depends_on = [ google_vpc_access_connector.disearch_vpc_connector ]
}

resource "google_compute_subnetwork" "uscentral_disearch_vpc01_subnet1010016_gke" {
  name          = var.gke_subnet_name
  ip_cidr_range = "10.1.0.0/16"
  network       = "default"
  region        = var.region
  private_ip_google_access = true

  secondary_ip_range {
    range_name = "k8s-pod-range"
    ip_cidr_range = "10.100.0.0/16"
  }

  secondary_ip_range {
    range_name = "k8s-services-range"
    ip_cidr_range = "10.101.0.0/16"
  }
  depends_on = [ google_compute_subnetwork.uscentral_disearch_vpc01_subnet1000024 ]

} 




//SUBNETS ENDS HERE ----------------------------------------------------------------








//STORAGE STARTS HERE -------------------------------------------------------------

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}


resource "google_storage_bucket" "disearch_storage_bucket" {
  name     = "${var.storage_bucket_name}-${random_string.bucket_suffix.result}"
  project  = var.projectName
  location = var.region
  uniform_bucket_level_access = false

    depends_on = [
    google_project_service.storage_api,
    google_project_service.storage,
  ]
}



resource "google_compute_disk" "neo4j-disk" {
  name  = "pd-ssd-disk-1"
  size  = 50
  type  = "pd-ssd"
  zone  = "us-central1-c"
  depends_on = [
    google_project_service.storage_api,
    google_project_service.storage,
  ]
}

//STORAGE ENDS HERE -------------------------------------------------------------


















//DATABASE STARTS HEREE ----------------------------------------------------------




resource "google_sql_database_instance" "disearch_db_instance" {
  name             = var.db_instance_name_prefix   
  database_version = var.db_version
  project          = var.projectName
  region           = var.region
  depends_on = [google_service_networking_connection.peering_connection]

  // Specify the network and do not assign IP
  settings {
    tier = "db-custom-1-3840"  # Equivalent to 1 CPU and 3840MiB memory
    disk_size       = var.db_instance_disk_size
    disk_autoresize = true

    ip_configuration {
      ipv4_enabled = false
      private_network = "projects/${var.projectName}/global/networks/default"
      enable_private_path_for_google_cloud_services = true
    }
  }

  deletion_protection = false
}

resource "google_sql_user" "postgres_user" {
  instance    = google_sql_database_instance.disearch_db_instance.name
  name        = var.db_username
  password    = var.db_password
}





//DATABASE STARTS HEREE ----------------------------------------------------------













//GKE CLUSTER STARTS HERE ---------------------------------------------------------




resource "google_container_cluster" "disearch_cluster" {
  name                     = var.gke_cluster_name
  location                 = var.location
  network                  = "default"
  subnetwork               = google_compute_subnetwork.uscentral_disearch_vpc01_subnet1010016_gke.name
  remove_default_node_pool = true
  initial_node_count       = 1
  
  node_config {
    service_account = "terraform@${var.projectName}.iam.gserviceaccount.com"
  }
  release_channel {
    channel = "UNSPECIFIED"
  }
  ip_allocation_policy {
    cluster_secondary_range_name  = "k8s-pod-range"
    services_secondary_range_name = "k8s-services-range"
  }

  # private_cluster_config {
  #   enable_private_nodes    = true
  #   enable_private_endpoint = true
  #   master_ipv4_cidr_block  = "10.8.0.0/28"
  # }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "10.1.0.0/16"
    }
    cidr_blocks {
      cidr_block = "111.88.136.0/24"
    }
    cidr_blocks{
      cidr_block = "35.228.11.0/24"
    }
  }
  monitoring_service = var.stackdriver_monitoring != "false" ? "monitoring.googleapis.com/kubernetes" : ""
  logging_service = var.stackdriver_logging != "false" ? "logging.googleapis.com/kubernetes" : ""
  depends_on = [ google_project_service.enable_container]


}







//GKE CLUSTER ENDS HERE ------------------------------------------------------------








//CLUSTER NODE POOL STARTS HERE ------------------------------------------------




resource "google_service_account" "disearch_gke_service_account" {
  account_id   = "disearch-gke-serviceaccount"
  display_name = "Service Account"

}


resource "google_container_node_pool" "general" {
  name    = "general"
  cluster = google_container_cluster.disearch_cluster.id
  node_count = 7
  version = var.gke_cluster_version

  autoscaling {
    # Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count.
    min_node_count = 7

    # Maximum number of nodes in the NodePool. Must be >= min_node_count.
    max_node_count = 20
  }

  management {
    auto_repair = true
    auto_upgrade = false
  }

  node_config {
    preemptible = false
    machine_type = var.gke_nodes_machine_type

    labels = {
        role = "general"
    }

    service_account = "terraform@${var.projectName}.iam.gserviceaccount.com"
    oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  depends_on = [ google_container_cluster.disearch_cluster ]
}


resource "google_container_node_pool" "pool-16" {
  name    = "pool-16"
  cluster = google_container_cluster.disearch_cluster.id
  node_count = 1
  version = var.gke_cluster_version

  autoscaling {
    # Minimum number of nodes in the NodePool. Must be >=0 and <= max_node_count.
    min_node_count = 1

    # Maximum number of nodes in the NodePool. Must be >= min_node_count.
    max_node_count = 10
  }

  management {
    auto_repair = true
    auto_upgrade = false
  }

  node_config {
    preemptible = false
    machine_type = "e2-standard-4"

    labels = {
        role = "general"
    }

    service_account = "terraform@${var.projectName}.iam.gserviceaccount.com"
    oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  depends_on = [ google_container_cluster.disearch_cluster ]
}







//CLUSTER NODE POOL ENDS HERE ------------------------------------------------


resource "time_sleep" "wait_360_seconds" {
  depends_on = [ google_container_node_pool.general ]

  create_duration = "360s"
}


resource "null_resource" "kubectl" {
    provisioner "local-exec" {
        command = "gcloud container clusters get-credentials ${var.gke_cluster_name}  --region=${var.location}"
    }
    depends_on = [ time_sleep.wait_360_seconds ]
}



resource "time_sleep" "wait_90_seconds" {
  depends_on = [ null_resource.kubectl ]

  create_duration = "90s"
}

//KUBECONFIG TEMPLATE STARTS HERE ------------------------------------------------





data "google_client_config" "default" { depends_on = [ time_sleep.wait_90_seconds ] }


data "template_file" "kubeconfig" {
  template = file("./kubeconfig.tpl")

  vars = {
    cluster_name           = var.gke_cluster_name
    cluster_endpoint       = "https://${google_container_cluster.disearch_cluster.endpoint}"
    cluster_ca_certificate = google_container_cluster.disearch_cluster.master_auth[0].cluster_ca_certificate
  }
  depends_on = [ data.google_client_config.default ]
}

resource "local_file" "kubeconfig" {
  content  = data.template_file.kubeconfig.rendered
  filename = "kubeconfig.yaml"
  depends_on = [ data.template_file.kubeconfig ]
}






//KUBECONFIG TEMPLATE ENDS HERE ------------------------------------------------



resource "null_resource" "gke_deployment" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<-EOT
          kubectl apply -f ./gke_cluster/parsrDeployment.yaml
          kubectl apply -f ./gke_cluster/parsrService.yaml
          kubectl apply -f ./gke_cluster/unstructured.yaml
          kubectl apply -f ./gke_cluster/unstructuredService.yaml
    EOT
    when = create
  }
  depends_on = [ local_file.kubeconfig ]
}




//DOCUMENT AI STARTS HERE -------------------------------------------------------------------





resource "google_document_ai_processor" "general_ocr_processor" {
  display_name = "General Document OCR Processor"
  project      = var.projectName
  location     = "us"
  type         = "OCR_PROCESSOR"
}





//DOCUMENT AI ENDS HERE -------------------------------------------------------------------




//Additional 120 Second Delay

resource "time_sleep" "wait_another_120_seconds" {
  depends_on = [ local_file.kubeconfig ]

  create_duration = "120s"
}







//Hydrating Google Secret Manager using the Credentials collected.

//VARIABLE ca_cert STATUS: DONE
resource "google_secret_manager_secret" "es-certificate-key" {
  secret_id = "ca_cert"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}



//VARIABLE es_username STATUS: DONE
resource "google_secret_manager_secret" "es-username-key" {
  secret_id = "es_username"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager ] 
}

resource "google_secret_manager_secret_version" "es-username-value" {
  secret = google_secret_manager_secret.es-username-key.id
  secret_data = "elastic"
  depends_on = [ google_project_service.enable_secretmanager ]

}




//VARIABLE es_password STATUS: DONE
resource "google_secret_manager_secret" "es-password-key" {
  secret_id = "es_password"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager ] 
}

resource "google_secret_manager_secret_version" "es-password-value" {
  secret = google_secret_manager_secret.es-password-key.id
  secret_data = "VLKSGyRviC162TvElByBPdnX"
  depends_on = [ google_project_service.enable_secretmanager ]

}



//VARIABLE storage_bucket STATUS: DONE


resource "google_secret_manager_secret" "storage-bucket-key" {
  secret_id = "storage_bucket"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "storage-bucket-value" {
  secret = google_secret_manager_secret.storage-bucket-key.id
  secret_data = google_storage_bucket.disearch_storage_bucket.name
  depends_on = [ google_storage_bucket.disearch_storage_bucket ]

}

//VARIABLE gpt_key STATUS: DONE

resource "google_secret_manager_secret" "gpt-key" {
  secret_id = "gpt_key"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager ]
}

resource "google_secret_manager_secret_version" "gpt-value" {
  secret = google_secret_manager_secret.gpt-key.id
  secret_data = file("~/gpt.key")
  depends_on = [ google_project_service.enable_secretmanager ]

}


//VARIABLE DB_HOST STATUS: DONE

resource "google_secret_manager_secret" "db-host-key" {
  secret_id = "DB_HOST"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "db-host-value" {
  secret = google_secret_manager_secret.db-host-key.id
  secret_data = tostring(google_sql_database_instance.disearch_db_instance.private_ip_address)
  depends_on = [ google_sql_database_instance.disearch_db_instance ]
} 


//VARIABLE DB_PASSWORD STATUS: DONE

resource "google_secret_manager_secret" "db-password-key" {
  secret_id = "DB_PASSWORD"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "db-password-value" {
  secret = google_secret_manager_secret.db-password-key.id
  secret_data = var.db_password
  depends_on = [ google_sql_database_instance.disearch_db_instance ]

}


//VARIABLE DB_USER Status: DONE

resource "google_secret_manager_secret" "db-user-key" {
  secret_id = "DB_USER"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "db-user-value" {
  secret = google_secret_manager_secret.db-user-key.id
  secret_data = var.db_username
  depends_on = [ google_sql_database_instance.disearch_db_instance ]

}


//VARUABLE GCP_BUCKET STATUS: DONE

resource "google_secret_manager_secret" "cloud-storage-bucket-key" {
  secret_id = "GCP_BUCKET"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "cloud-storage-bucket-value" {
  secret = google_secret_manager_secret.cloud-storage-bucket-key.id
  secret_data = google_storage_bucket.disearch_storage_bucket.name
  depends_on = [ google_storage_bucket.disearch_storage_bucket ]

}

//VARIABLE OPENAI_API_KEY STATUS: DONE

resource "google_secret_manager_secret" "openai-api-key" {
  secret_id = "OPENAI_API_KEY"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager ]
}

resource "google_secret_manager_secret_version" "openai-api-value" {
  secret = google_secret_manager_secret.openai-api-key.id
  secret_data = file("~/gpt.key")
  depends_on = [ google_project_service.enable_secretmanager ]

}

//VARIABLE service_key STATUS: DONE

resource "google_secret_manager_secret" "service-account-key" {
  secret_id = "service_key"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "service-account-value" {
  secret = google_secret_manager_secret.service-account-key.id
  secret_data = file("/creds/${var.projectName}/secret.json")
  depends_on = [ google_project_service.enable_secretmanager ]

}



//VARIABLE AIRFLOW_PASSWORD STATUS: DONE
resource "google_secret_manager_secret" "airflow-password-key" {
  secret_id = "AIRFLOW_PASSWORD"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-password-value" {
  secret   = google_secret_manager_secret.airflow-password-key.id
  secret_data = "admin"  
}


//VARIABLE AIRFLOW_USER STATUS: DONE
resource "google_secret_manager_secret" "airflow-user-key" {
  secret_id = "AIRFLOW_USER"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-user-value" {
  secret   = google_secret_manager_secret.airflow-user-key.id
  secret_data = "admin"  
}


resource "google_secret_manager_secret" "airflow-webserver-key" {
  secret_id = "AIRFLOW_WEBSERVER"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}


resource "google_secret_manager_secret" "es-host-key" {
  secret_id = "es_host"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "es-host-value" {
  secret = google_secret_manager_secret.es-host-key.id
  secret_data = "https://disearch.es.us-east4.gcp.elastic-cloud.com"
  depends_on = [ google_project_service.enable_secretmanager ]

}


resource "google_secret_manager_secret" "image-table-url-key" {
  secret_id = "IMAGE_TABLE_URL"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}


resource "google_secret_manager_secret" "airflow-variables-deep-parser-url-key" {
  secret_id = "airflow-variables-deep-parser-url"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret" "airflow-variables-image-url-key" {
  secret_id = "airflow-variables-image-url"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}


//VARIABLE airflow-variables-location STATUS: DONEE
resource "google_secret_manager_secret" "airflow-variables-location-key" {
  secret_id = "airflow-variables-location"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-variables-location-value" {
  secret   = google_secret_manager_secret.airflow-variables-location-key.id
  secret_data = "us"  
}


resource "google_secret_manager_secret" "airflow-variables-neo4j-python-url-key" {
  secret_id = "airflow-variables-neo4j-python-url"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}


resource "google_secret_manager_secret" "airflow-variables-node-url-referer-key" {
  secret_id = "airflow-variables-node_url_referer"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret" "airflow-variables-node-url-refererv2-key" {
  secret_id = "airflow-variables-node-url-referer"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

//VARIABLE airflow-variables-openai-api-key STATUS: DONE
resource "google_secret_manager_secret" "airflow-variables-openai-api-key" {
  secret_id = "airflow-variables-openai-api-key"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-variables-openai-api-value" {
  secret = google_secret_manager_secret.airflow-variables-openai-api-key.id
  secret_data = file("~/gpt.key")
  depends_on = [ google_project_service.enable_secretmanager ]

}



//VARIABLE airflow-variables-paragraph-length STATUS: DONE
resource "google_secret_manager_secret" "airflow-variables-paragraph-length-key" {
  secret_id = "airflow-variables-paragraph-length"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-variables-paragraph-length-value" {
  secret   = google_secret_manager_secret.airflow-variables-paragraph-length-key.id
  secret_data = "200"  
}



//VARIABLE airflow-variables-processor-id STATUS: DONE
resource "google_secret_manager_secret" "airflow-variables-processor-id-key" {
  secret_id = "airflow-variables-processor-id"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-variables-processor-id-value" {
  secret   = google_secret_manager_secret.airflow-variables-processor-id-key.id
  secret_data = google_document_ai_processor.general_ocr_processor.name
}


data "google_project" "project" {
}

output "project_number" {
  value = data.google_project.project.number
}

//VARIABLE airflow-variables-project-id STATUS: DONE
resource "google_secret_manager_secret" "airflow-variables-project-id-key" {
  secret_id = "airflow-variables-project-id"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-variables-project-id-value" {
  secret  = google_secret_manager_secret.airflow-variables-project-id-key.id
  secret_data = data.google_project.project.number
}



//VARIABLE airflow-variables-secret-key STATUS: DONE
resource "google_secret_manager_secret" "airflow-variables-secret-key-key" {
  secret_id = "airflow-variables-secret-key"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-variables-secret-key-value" {
  secret   = google_secret_manager_secret.airflow-variables-secret-key-key.id
  secret_data = "h2ruCdmNENA02pHzyj/Y+Uw1RvTni1V6NUjqdY5BE/Z1jX8krwwj4xUiwCe5uP15"
}


//VARIABLE airflow-variables-service-key STATUS: DONE
resource "google_secret_manager_secret" "airflow-variables-service-key-key" {
  secret_id = "airflow-variables-service-key"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-variables-service-key-value" {
  secret = google_secret_manager_secret.airflow-variables-service-key-key.id
  secret_data = file("/creds/${var.projectName}/secret.json")
  depends_on = [ google_project_service.enable_secretmanager ]
}



//VARIABLE = airflow-variables-storage-bucket Status: DONE

resource "google_secret_manager_secret" "airflow-variables-storage-bucket-key" {
  secret_id = "airflow-variables-storage-bucket"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-variables-storage-bucket-value" {
  secret = google_secret_manager_secret.airflow-variables-storage-bucket-key.id
  secret_data = google_storage_bucket.disearch_storage_bucket.name
  depends_on = [ google_storage_bucket.disearch_storage_bucket ]
}




resource "google_secret_manager_secret" "airflow-variables-unstructured-parser-url-key" {
  secret_id = "airflow-variables-unstructured-parser-url"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}



resource "google_secret_manager_secret" "airflow-variables-neo4j-url-key" {
  secret_id = "airflow-variables-neo4j-url"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret" "airflow-variables-neo4j-url-key2" {
  secret_id = "airflow-variables-neo4j_url"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}


resource "google_secret_manager_secret" "airflow-variables-neo4j-user-key" {
  secret_id = "airflow-variables-neo4j-user"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}


resource "google_secret_manager_secret_version" "airflow-variables-neo4j-user-value" {
  secret = google_secret_manager_secret.airflow-variables-neo4j-user-key.id
  secret_data = "admin"
  depends_on = [ google_storage_bucket.disearch_storage_bucket ]
}


resource "google_secret_manager_secret" "airflow-variables-neo4j-password-key" {
  secret_id = "airflow-variables-neo4j-password"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-variables-neo4j-password-value" {
  secret = google_secret_manager_secret.airflow-variables-neo4j-password-key.id
  secret_data = "admin"
  depends_on = [ google_storage_bucket.disearch_storage_bucket ]
}


resource "google_secret_manager_secret" "airflow-variables-neo4j-user-key2" {
  secret_id = "airflow-variables-neo4j_username"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}


resource "google_secret_manager_secret_version" "airflow-variables-neo4j-user-value2" {
  secret = google_secret_manager_secret.airflow-variables-neo4j-user-key2.id
  secret_data = "admin"
  depends_on = [ google_storage_bucket.disearch_storage_bucket ]
}


resource "google_secret_manager_secret" "airflow-variables-neo4j-password-key2" {
  secret_id = "airflow-variables-neo4j_password"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}

resource "google_secret_manager_secret_version" "airflow-variables-neo4j-password-value2" {
  secret = google_secret_manager_secret.airflow-variables-neo4j-password-key2.id
  secret_data = "admin"
  depends_on = [ google_storage_bucket.disearch_storage_bucket ]
}




resource "google_secret_manager_secret" "airflow-variables-neo4j-gcp-key" {
  secret_id = "airflow-variables-neo4j-gcp"

  replication {
   automatic = true
  }
  depends_on = [ google_project_service.enable_secretmanager]
}
