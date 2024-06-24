# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


variable "VCN-CIDR" {
  type = list(string)
  default = ["10.0.0.0/16"]
}

variable "VCN-name" {
  default = "oke-vcn"
}

variable "K8SAPIEndPointSubnet-CIDR" {
  default = "10.0.0.0/28"
}

variable "K8SLBSubnet-CIDR" {
  default = "10.0.20.0/24"
}

variable "K8SNodePoolSubnet-CIDR" {
  default = "10.0.10.0/24"
}
variable "K8SOperatorSubnet-CIDR" {
  default = "10.0.30.0/24"
}
variable "K8SPodSubnet-CIDR" {
  default = "10.0.5.0/24"
}
variable "K8SSignallingSubnet-CIDR" {
  default = "10.0.6.0/24"
}

variable "add_subnet" {
 default = false
}

variable "subnet_number" {
 default = 0
}


variable "additionalsubnet_name" {
  type = list
  default = []
}

variable "additionalsubnet-CIDR" {
  type = list
  default = []
}
variable "zone_name" {
 default = 0
}
