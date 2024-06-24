locals{
vcn_id_native = var.cni_type == "native" ? module.terraform_oci_networking_native[0].provisioned_networking_resources.vcns["OKE-VCN-KEY"].id : ""
api_nsg_ids_native = var.cni_type == "native" ? module.terraform_oci_networking_native[0].provisioned_networking_resources.network_security_groups["NSG-API-KEY"].id : ""
api_id_native = var.cni_type == "native" ? module.terraform_oci_networking_native[0].provisioned_networking_resources.subnets["API-SUBNET-KEY"].id : ""
svc_id_native = var.cni_type == "native" ? module.terraform_oci_networking_native[0].provisioned_networking_resources.subnets["SERVICES-SUBNET-KEY"].id : ""
worker_nsg_ids_native =  var.cni_type == "native" ? module.terraform_oci_networking_native[0].provisioned_networking_resources.network_security_groups["NSG-WORKERS-KEY"].id : ""
worker_id_native = var.cni_type == "native" ? module.terraform_oci_networking_native[0].provisioned_networking_resources.subnets["WORKERS-SUBNET-KEY"].id : ""
pods_id_native = var.cni_type == "native" ? module.terraform_oci_networking_native[0].provisioned_networking_resources.subnets["PODS-SUBNET-KEY"].id : ""
pods_nsg_ids_native = var.cni_type == "native" ? module.terraform_oci_networking_native[0].provisioned_networking_resources.network_security_groups["NSG-PODS-KEY"].id : ""
}
locals {
clusters_configuration_native = {
  default_compartment_id         = local.appdev_compartment_id
  clusters = {
    OKE1 = {
      kubernetes_version = var.kubernetes_version
      name = var.ClusterName
      is_enhanced = var.is_enhanced
      cni_type = var.cni_type
      networking = {
        vcn_id             = local.vcn_id_native
        api_endpoint_nsg_ids   = ["${local.api_nsg_ids_native}"]
        api_endpoint_subnet_id = local.api_id_native
        services_subnet_id = ["${local.svc_id_native}"]
      }
    }
  }
}

workers_configuration_native = {
  default_compartment_id      = local.appdev_compartment_id
  #default_ssh_public_key_path = "files/worker_key.pub"
  node_pools = merge(
  {
    NODEPOOL1 = {
      cluster_id = "OKE1"
      name       = var.nodepool_name
      size       = var.node_pool_size
      networking = {
        workers_nsg_ids   = ["${local.worker_nsg_ids_native}"]
        workers_subnet_id = local.worker_id_native
        pods_subnet_id    = local.pods_id_native
        pods_nsg_ids      = ["${local.pods_nsg_ids_native}"]
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
        cloud_init = {
		  script_file = var.cpu_pinning ? "files/cloud-init-wn_cpupinning.sh" : "files/cloud-init-wn.sh"
		}

      }
    }},
	{
	for i in range(0,local.nodepool_quantity) : "NODEPOOL${i+2}" => { 
	  cluster_id = "OKE{i+1}"
      name       = var.additionalnodepool_name
      size       = var.node_pool_size2
      networking = {
        workers_nsg_ids   = ["${local.worker_nsg_ids}"]
        workers_subnet_id = local.worker_id
		pods_subnet_id    = local.pods_id_native
        pods_nsg_ids      = ["${local.pods_nsg_ids_native}"]
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
        cloud_init = {
		  script_file = var.cpu_pinning2 == "true" ? "files/cloud-init-wn_cpupinning.sh" : "files/cloud-init-wn.sh"
		}

      }
	}
	})

  }
}
