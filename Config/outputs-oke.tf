
# Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "clusters" {
  value = var.cni_type == "flannel" ? module.oke_flannel[0].clusters : module.oke_native[0].clusters
}

output "node_pools" {
  value = var.cni_type == "flannel" ? module.oke_flannel[0].node_pools : module.oke_native[0].node_pools
}

output "sessions" {
  value = {for k, v in module.bastion.sessions : k => replace(replace(replace(v, "\"", "'"), "<privateKey>", local.ssh_private_key), "<localPort>", "6443")}
}
