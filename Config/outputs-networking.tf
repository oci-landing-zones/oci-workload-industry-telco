# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "provisioned_networking_resources" {
  description = "Provisioned networking resources"
  value       = var.cni_type == "flannel" ? module.terraform_oci_networking_flannel[0].provisioned_networking_resources : module.terraform_oci_networking_native[0].provisioned_networking_resources
}




