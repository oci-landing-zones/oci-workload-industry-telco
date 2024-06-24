data "oci_containerengine_node_pool" "test_node_pool" {
    #Required
    node_pool_id = var.nodepool_id
}
resource "null_resource" "add_sriov-1" { 
  count = var.sriov ? var.node_pool_size : 0
  provisioner "local-exec" {
    
    command = format("%s %s", replace(replace(replace(replace(var.session, "\"", "'"), "<privateKey>", var.ssh_private_key), "-o ProxyCommand", "-o StrictHostKeyChecking=no -o ProxyCommand"), "-W", "-o StrictHostKeyChecking=no -W"), "-y -x 'oci compute instance update --instance-id ${data.oci_containerengine_node_pool.test_node_pool.nodes[count.index].id} --launch-options {\\\"network-type\\\":\\\"VFIO\\\"}  --force'") 
  }

}

resource "time_sleep" "wait_5min" {
  depends_on = [null_resource.add_sriov-1]
  create_duration = "300s"
}

resource "oci_core_vnic_attachment" "vnic-1" {
  depends_on = [time_sleep.wait_5min]
  count = var.sriov  ? var.node_pool_size :0
  create_vnic_details {
    display_name  = "vnic0"
    subnet_id     = var.worker_id
    defined_tags  = {}
  }
  instance_id  = data.oci_containerengine_node_pool.test_node_pool.nodes[count.index].id
}

resource "null_resource" "add_sriov-2" { 
  depends_on = [oci_core_vnic_attachment.vnic-1]
  count = var.sriov ? var.node_pool_size : 0
  provisioner "local-exec" {
    
    command = format("%s %s", replace(replace(replace(replace(var.session, "\"", "'"), "<privateKey>", var.ssh_private_key), "-o ProxyCommand", "-o StrictHostKeyChecking=no -o ProxyCommand"), "-W", "-o StrictHostKeyChecking=no -W"), "-y -x 'oci compute instance action --instance-id ${data.oci_containerengine_node_pool.test_node_pool.nodes[count.index].id} --action SOFTRESET'") 
  }

}

resource "time_sleep" "wait_2min" {
  depends_on = [null_resource.add_sriov-2]
  create_duration = "120s"
}
