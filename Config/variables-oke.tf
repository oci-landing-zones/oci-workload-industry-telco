# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.



#variable "ssh_private_key" {
#  type = string
#  default = "~/.ssh/new_ssh.key"
#}
variable "ClusterName" {
  default = ""
}
variable "kubernetes_version" {
  default = ""
}
variable "cni_type" {
  default = "flannel"
}
variable "is_enhanced" {
  default = false
}
variable "kubernetes_version_np" {
  default = ""
}
variable "kubernetes_version_np2" {
  default = ""
}
variable "nodepool_name" {
  default = ""
}
variable "operator-image" {
  default = ""
}
variable "Shape" {
  default = ""
}
variable "Flex_shape_memory" {
  default = ""
}
variable "Flex_shape_ocpus" {
  default = ""
}
variable "node_pool_size" {
  default = ""
}
variable "bootvolume" {
  default = ""
}

variable "additionalnodepool_name" {
  default = ""
}
variable "Shape2" {
  default = ""
}
variable "add_nodepool" {
  default = false
}

variable "node_pool_size2" {
  default = 0
}
variable "Flex_shape_memory2" {
  default = 12
}

variable "Flex_shape_ocpus2" {
  default = 6
}
variable "multus" {
  default = false
}
variable "sriov" {
  default = false
}
variable "sriov2" {
  default = false
}
variable "cpu_pinning" {
  default = false
}
variable "cpu_pinning2" {
  default = false
}
variable "cpu" {
  default = 0
}
variable "cpu2" {
  default = 0
}
variable "hp" {
  default = false
}
variable "hp_size" {
  default = "2"
}
variable "hp2" {
  default = false
}
variable "hp_size2" {
  default = "2"
}
variable "olm" {
  default = false
}
variable "metric_server" {
  default = false
}

#Keys
variable "worker_key" {
  default = ""
}
variable "worker_key2" {
  default = ""
}
variable "operator_key_public" {
  default = ""
}
variable "operator_key_private" {
  default = ""
}
