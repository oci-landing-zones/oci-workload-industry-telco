# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "service_label" {
    value = local.display_outputs == true ? var.service_label : null
}

output "compartments" {
    value = local.display_outputs == true && var.extend_landing_zone_to_new_region == false ? merge({for k, v in module.lz_compartments.compartments : k => {name:v.name, id:v.id, parent_id:v.compartment_id, time_created:v.time_created}}, length(module.lz_top_compartment) > 0 ? {for k, v in module.lz_top_compartment[0].compartments : k => {name:v.name, id:v.id, parent_id:v.compartment_id, time_created:v.time_created}} : {}) : null
}



output "scanning_host_recipes" {
    value = length(module.lz_scanning) > 0 ? module.lz_scanning[0].scanning_host_recipes : null
}
output "scanning_container_recipes" {
    value = length(module.lz_scanning) > 0 ? module.lz_scanning[0].scanning_container_recipes : null
}

output "scanning_host_targets" {
    value = length(module.lz_scanning) > 0 ? module.lz_scanning[0].scanning_host_targets : null
}
output "scanning_container_targets" {
    value = length(module.lz_scanning) > 0 ? module.lz_scanning[0].scanning_container_targets : null
}



output "cloud_guard_target" {
    value = length(module.lz_cloud_guard) > 0 ? module.lz_cloud_guard[0].targets : null
}


output "cis_level" {
    value = local.display_outputs == true ? var.cis_level : null
}

output "region" {
    value = local.display_outputs == true ? var.region : null
}

output "release" {
    value = local.display_outputs == true ? (fileexists("${path.module}/../release.txt") ? file("${path.module}/../release.txt") : "unknown") : null
}
