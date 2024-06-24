locals {
  oke_cluster_id = module.oke_flannel[0].clusters["OKE1"].id
}
locals {
  dynamic_groups_configuration_dns = {
  dynamic_groups = {  
    DNS-DYN-GROUP : { 
      name : "${var.service_label}-dns-dynamic-group",  
      description : "Dynamic group for DNS",      
      matching_rule : "instance.compartment.id = '${local.appdev_compartment_id}'" 
    }
  }  
}

 policies_configuration_dns = {
   supplied_policies : {
     "DNS-POLICY" : {
       name : "${var.service_label}-dns-policy"
       description : "DNS policy."
       compartment_id : "${local.network_compartment_id}"
       statements : [
         "Allow dynamic-group ${var.service_label}-dns-dynamic-group to manage dns in compartment id ${local.network_compartment_id}",
         "Allow any-user to manage dns in compartment id ${local.network_compartment_id} where all {request.principal.type='workload',request.principal.cluster_id='${local.oke_cluster_id}',request.principal.service_account='external-dns'}"
       ]            
     }
   } 
  }
}