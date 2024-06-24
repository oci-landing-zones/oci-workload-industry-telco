data "oci_containerengine_node_pool" "test_node_pool" {
    #Required
    node_pool_id = var.nodepool_id
}


resource "null_resource" "restart_nodes" { 
  count = var.cpu_pinning ? var.node_pool_size : 0
  provisioner "local-exec" {
    
    command = format("%s %s", replace(replace(replace(replace(var.session, "\"", "'"), "<privateKey>", var.ssh_private_key), "-o ProxyCommand", "-o StrictHostKeyChecking=no -o ProxyCommand"), "-W", "-o StrictHostKeyChecking=no -W"), "-y -x 'oci compute instance action --instance-id ${data.oci_containerengine_node_pool.test_node_pool.nodes[count.index].id} --action SOFTRESET'") 
  }

}

resource "time_sleep" "wait_2min" {
  depends_on = [null_resource.restart_nodes]
  create_duration = "120s"
}
