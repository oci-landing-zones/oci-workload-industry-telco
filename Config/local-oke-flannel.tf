locals{
vcn_id = var.cni_type == "flannel" ? module.terraform_oci_networking_flannel[0].provisioned_networking_resources.vcns["OKE-VCN-KEY"].id : ""
api_nsg_ids = var.cni_type == "flannel" ? module.terraform_oci_networking_flannel[0].provisioned_networking_resources.network_security_groups["NSG-API-KEY"].id : ""
api_id = var.cni_type == "flannel" ? module.terraform_oci_networking_flannel[0].provisioned_networking_resources.subnets["API-SUBNET-KEY"].id : ""
svc_id = var.cni_type == "flannel" ? module.terraform_oci_networking_flannel[0].provisioned_networking_resources.subnets["SERVICES-SUBNET-KEY"].id : ""
worker_nsg_ids =  var.cni_type == "flannel" ? module.terraform_oci_networking_flannel[0].provisioned_networking_resources.network_security_groups["NSG-WORKERS-KEY"].id : ""
worker_id = var.cni_type == "flannel" ? module.terraform_oci_networking_flannel[0].provisioned_networking_resources.subnets["WORKERS-SUBNET-KEY"].id : ""
operator_id = var.cni_type == "flannel" ? module.terraform_oci_networking_flannel[0].provisioned_networking_resources.subnets["OPERATOR-SUBNET-KEY"].id : module.terraform_oci_networking_native[0].provisioned_networking_resources.subnets["OPERATOR-SUBNET-KEY"].id
operator_nsg_ids = var.cni_type == "flannel" ? module.terraform_oci_networking_flannel[0].provisioned_networking_resources.network_security_groups["NSG-OPERATOR-KEY"].id : module.terraform_oci_networking_native[0].provisioned_networking_resources.network_security_groups["NSG-OPERATOR-KEY"].id

nodepool_quantity = var.add_nodepool ? 1 : 0
}
resource "local_file" "private_key_file" {
  content  = base64decode(var.operator_key_private)
  filename = "${path.module}/files/session_key.key"
  file_permission = "0600"
}

locals{

clusters_configuration_flannel = {
  default_compartment_id = local.appdev_compartment_id
  clusters = {
    OKE1 = {
      kubernetes_version = var.kubernetes_version
      name = var.ClusterName
      is_enhanced = var.is_enhanced
      cni_type = var.cni_type  
      networking = {
        vcn_id                 = local.vcn_id
        api_endpoint_nsg_ids   = ["${local.api_nsg_ids}"]
        api_endpoint_subnet_id = local.api_id
        services_subnet_id     = ["${local.svc_id}"]
      }
    }
  }
}

workers_configuration_flannel = {
  node_pools = merge(
  {
    NODEPOOL1 = {
      cluster_id = "OKE1"
      kubernetes_version = var.kubernetes_version_np
      name       = var.nodepool_name
      size       = var.node_pool_size
      networking = {
        workers_nsg_ids   = ["${local.worker_nsg_ids}"]
        workers_subnet_id = local.worker_id
      }
      node_config_details = {
        ssh_public_key_path = base64decode(var.worker_key)
        node_shape = var.Shape
        flex_shape_settings = {
          memory = var.Flex_shape_memory
          ocpus = var.Flex_shape_ocpus 
        }
        boot_volume = {
          size = var.bootvolume
        }
        encryption = {
          enable_encrypt_in_transit = true
        }
	cloud_init = {
		  script_file = local_file.cloud_init_cpu_hp.filename 
		}
      }
    }},
	{
	for i in range(0,local.nodepool_quantity) : "NODEPOOL${i+2}" => { 
	  cluster_id = "OKE1"
      kubernetes_version = var.kubernetes_version_np2
      name       = var.additionalnodepool_name
      size       = var.node_pool_size2
      networking = {
        workers_nsg_ids   = ["${local.worker_nsg_ids}"]
        workers_subnet_id = local.worker_id
      }
      node_config_details = {
        ssh_public_key_path = base64decode(var.worker_key2)
        node_shape = var.Shape2
        flex_shape_settings = {
          memory = var.Flex_shape_memory2
          ocpus = var.Flex_shape_ocpus2
        }
        boot_volume = {
          size = var.bootvolume
        }
        encryption = {
          enable_encrypt_in_transit = true
        }
        cloud_init = {
		  script_file = local_file.cloud_init_cpu_hp2[i].filename 
		}
      }
	}
	})
}


instances_configuration = {
  default_compartment_id      = local.appdev_compartment_id
  default_subnet_id           = local.operator_id
  default_ssh_public_key_path = base64decode(var.operator_key_public)
  instances = {
    INSTANCE-1 = {
      shape = "VM.Standard.E4.Flex"
      name  = "OKE operator instance"
      placement = {
        availability_domain = 1
        fault_domain        = 1
      }
      boot_volume = {
        size                          = 100
        preserve_on_instance_deletion = false
        secure_boot = var.cis_level == "2" ? true : false
      }
      networking = {
        hostname                = "oke-operator-instance"
        network_security_groups = ["${local.operator_nsg_ids}"]
      }
      image = {
        id = var.operator-image # "Oracle-Linux-Cloud-Developer-8.7-2023.04.28-1" Platform image
      }
      encryption = {
        encrypt_in_transit_on_instance_create = true
      }
      cloud_agent = {
        plugins = [
          { name = "Bastion", enabled = true }
        ]
      }
             
     }
    }
  }

bastions_configuration = {
  enable_cidr_check = false
  bastions = {
    BASTION-1 = {
      bastion_type          = "STANDARD"
      compartment_id        = local.appdev_compartment_id
      subnet_id             = local.operator_id
      cidr_block_allow_list = ["10.0.3.0/28", "10.0.2.0/24","0.0.0.0/0"]
      name                  = "Bastion1"
    }
  }
}

sessions_configuration = {
  default_ssh_public_key = base64decode(var.operator_key_public)
  sessions = {
    SESSION-1 = {
      bastion_id      = "BASTION-1"
      #ssh_public_key  = "files/session_key.pub"
      session_type    = "MANAGED_SSH"
      target_user     = "opc"
      target_resource = "INSTANCE-1"
      target_port     = "22"
      session_name    = "Session-1"
    }
  }
}


ssh_private_key = local_file.private_key_file.filename # Used for generating the command for managed ssh. The private key contents aren't sent anywhere.

dynamic_groups_configuration_oke = {
  dynamic_groups = {  
    OKE-OPERATOR-DYN-GROUP : { 
      name : "${var.service_label}-oke-operator-dynamic-group",  
      description : "Dynamic group for OKE operator.",      
      matching_rule : "instance.compartment.id = '${local.appdev_compartment_id}'" 
    }
  }  
}

policies_configuration_oke = {
  supplied_policies : {
    "OKE-OPERATOR-POLICY" : {
      name : "${var.service_label}-oke-operator-policy"
      description : "OKE operator policy."
      compartment_id : "${local.appdev_compartment_id}"
      statements : [
        "allow dynamic-group ${var.service_label}-oke-operator-dynamic-group to manage cluster-family in compartment id ${local.appdev_compartment_id}",
        "allow dynamic-group ${var.service_label}-oke-operator-dynamic-group to manage instances in compartment id ${local.appdev_compartment_id}"
      ]            
    }
  } 
}

}
