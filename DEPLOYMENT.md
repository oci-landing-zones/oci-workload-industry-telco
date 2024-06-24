# OCI Telco Landing Zone


## User

The OCI Telco Landing Zone should be deployed by a user who is a member of the Administrators group for the tenancy. 

## Region

The OCI Telco Landing Zone can be deployed in any region to which the tenancy is subscribed to.

## Tenancy

The tenancy you intend to deploy the OCI Telco Landing Zone to.

## Landing Zone Deployment
To deploy using ORM, the stack must be imported into the console in one of 2 ways:

Use the `Deploy to Oracle Cloud` button, which will take you directly to OCI Resource Manager if you are logged in. You can skip to step 11 if you use this.
Or you can select the stack manually through the console starting from step 1. 

1. From the console home page, navigate to `Developer Services -> Resource Manager -> Stacks`
2. Select the compartment you want to create the stack in and select `Create stack`.
3. Select `Source code control system` for the Terraform source.
4. In the `Stack Configuration` box, under `Source Code Management Type`, select `GitHub`. 
5. Under `Configuration source provider`, if you have a provider set up for public GitHub, you can select it, then skip to step 9. Otherwise select `Create configuration source provider`. 
6. If you do not already have a Personal Access Token for your GitHub account, log in to GitHub and create one. The option can be found under `Settings -> Developer settings -> Personal access tokens -> Tokens (classic)` on the [GitHub site](https://github.com). The token must have the `repo` scope. 
7. To create the configuration provider for GitHub in OCI, fill in the "Create configuration source provider" form as follows: 
    * Name: GitHub
    * Description: (optional) Public Github Repositories
    * Select the `Public Endpoint` option
    * Type: GitHub
    * Server URL: https://github.com/
    * Personal Access Token: #Your Personal Access Token# 
8. Click `Create` to create the config provider
9. For Repository select `oci-workload-industry-telco`
10. For Branch select `main`
11. for Working directory, select `config`    
12. For Name, give the stack a name or accept the default.
13. For the Create in Compartment dropdown, select the compartment to store the Stack.
14. For Terraform Version dropdown, make sure to select 1.2.x at least. Lower Terraform versions are not supported.

After completing the Stack Creation Wizard, the subsequent step prompts for variables values. 

After filling in the required input variables, click next to review the stack values and create the stack.  

In the Stack page use the appropriate buttons to plan/apply/destroy your stack.

## Accesing the Operator Instance

After deploying the Landing Zone, you can access the operator instance  to manage the OKE cluster by using the OCI bastion service.
To create a session, follow the steps described below:

1. Open the navigation menu and click Identity & Security. Click Bastion.

2. Under List scope, select the security compartment used for the Landing Zone.

3. Click on the Bastion1 bastion service.

4. Click on "Create session".

5. Choose Managed SSH session to connect to a Compute instance that has a running OpenSSH server and has Oracle Cloud Agent and enabled.

6. Enter a valid operating system username for the target instance.
The default username on most platform images is opc.

7. Select the target Compute instance. If needed, change the compartment to find the instance. Only active instances are listed.

8. Enter a display name for the new session.
Avoid entering any confidential information in this field.

9. Under Add SSH key, provide the public key file of the SSH key pair that you want to use for the session.
Later, when you connect to the session, you must provide the private key of the same SSH key pair.

10. (Optional) To change the maximum amount of time that the session can remain active, click Show advanced options, and then enter a value for Maximum session time-to-live.
Provide a value that's at least 30 minutes, but doesn't exceed the maximum TTL of the bastion. The default is 180 minutes or three hours.

You can also delete a session before it expires.

11.(Optional) If you chose to create a Managed SSH session, change the specific port or IP address to connect to on the target compute instance.
By default, the session uses the primary IP address of the instance and port 22.

  a. Click Show advanced options.
  b. Update the target Compute instance port.
  c. Select a target Compute instance IP address.

12. When you're finished, click Create session.

13. After creating the session, copy the SSH command.

14. Replace the private key with the key chosen for the session and run the SSH command.

## Post-deployment Steps

### DNS Zone Configuration
After deploying the Landing Zone, the DNS dynamic group needs to be manually updated for the DNS A records to be created automatically when deploying a load balancer service.
To edit the dynamic group, follow these steps:
1. Navigate to Identity and Access Management and click on `Domains`.
2. Click on the `Default` domain.
3. In the menu on the left, click on `Dynamic Groups` and locate the dynamic group that ends with `dns-dynamic-group`.
4. In the dynamic group, click  on `Edit all matching rules`.
5. Add `All {}` to the instance compartment id. For example: All {instance.compartment.id = 'ocid1.compartment.oc1....'}
6. Click on `Save`.

### Configurating Customer Managed Keys
This Landing Zone creates a Vault within the security compartment for customer to create or upload their master encryption keys.
To comply with the CIS OCI Foundations Benchmark v1.2, customers that have chosen CIS level 2 must execute the steps below to enforce customer keys on the operator instance and the OKE worker nodes:
1. On the OCI Console, navigate  to Identity & Security --> Key Management & Secret Management --> Vault.
2. In the Vault page, make sure that you select the Landing Zone's security compartment.
3. The Vault must be show. Click on it to open it.
4. Click on Create Key to create or import your keys.
5. Create the following policy in the workload compartment of the Landing Zone.
allow dynamic-group <service-label>-oke-operator-dynamic-group to manage volume-family in compartment id <workload_compartment-ocid>
For example: if the service label defined in the stack is TelcoLZ, the policy would look like this: allow dynamic-group TelcoLZ-oke-operator-dynamic-group to manage volume-family in compartment id ocid1.compartment.oc1..aaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
6. Create the following policy in the security compartment of the Landing Zone.
allow dynamic-group <service-label>-oke-operator-dynamic-group to manage all-resources in compartment id <security_compartment-ocid>
For example: if the service label defined in the stack is TelcoLZ, then the policy would llook like this: allow dynamic-group TelcoLZ-oke-operator-dynamic-group to manage all-resources in compartment id ocid1.compartment.oc1..aaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
7. Log into the operator instance and run the script [update_kms_keys.sh](/Config/update_kms_keys.sh) from the operator instance. To run the script, execute the following command: sh update_kms_keys.sh <availability-domain> <workload_compartment-ocid> <key-ocid>
For example: sh update_kms_keys.sh raMT:UK-LONDON-1-AD-1 ocid1.compartment.oc1..aaaxxxxxxxxxxxxxxxx ocid1.key.oc1.uk-london-1.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

## LoadBalancer Services Deployment

### Type of Load Balancers

Oracle Cloud Infrastructure (OCI) offers two main types of load balancers:

Network Load Balancer (Layer 4): This acts like a traffic cop, directing incoming traffic based on simple rules like IP address and port number. It operates at the transport layer (layer 4) of the OSI model, so it doesn't analyze the content of the data packets. This makes it fast and efficient and it the recommended option for control plane and user plane LoadBalancer services.

Application Load Balancer (Layer 7): This is a more sophisticated option that works at the application layer (layer 7) of the OSI model. It inspects the contents of incoming traffic, such as HTTP headers and cookies, to make intelligent routing decisions. This allows for features like:

- Content-based routing: Sending traffic to specific servers based on the content of the request (e.g., sending login requests to a specific server).
- Health checks: Monitoring the health of backend servers and only directing traffic to healthy ones.
- SSL termination/offloading: Decrypting HTTPS traffic for backend servers that don't handle it themselves.

This load balancer is preferred for some Operations, Administration and Maintenance applications, such as a management GUI.

### Utilizing Load Balancers
When deploying an application on OKE, specific annotations can be used to choose the type of load balancer, the subnet it will use, whether a private IP or public IP will be used (when using public subnets), etc.
To find out more, go to https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingloadbalancer_topic-Summaryofannotations.htm.

Examples:

1. Using a Network Load Balancer with a specific subnet:
   a) The following annotations must be added to the service helm charts:
      oci.oraclecloud.com/load-balancer-type: "nlb"
      oci-network-load-balancer.oraclecloud.com/subnet: "<subnet-OCID>"
   
   b) if the subnet is public, add the following annotation to make sure that the network load balancer stays private: 
   oci-network-load-balancer.oraclecloud.com/internal: "true" 

2. Using a Load Balancer with a specific subnet:
   a) The following annotations must be added to the service helm charts:
      oci.oraclecloud.com/load-balancer-type: "lb"
      service.beta.kubernetes.io/oci-load-balancer-shape: "flexible"
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-min: "<min-value>"
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-max: "<max-value>"
   
   b) if the subnet is public, add the following annotation to make sure that the network load balancer stays private: 
   service.beta.kubernetes.io/oci-load-balancer-internal: "true"

### Automated A Record Provisioning to the DNS Zone
With the Landing Zone, a DNS record can automatically be populated in a private zone within the default view of the VCN's DNS resolver, for every LoadBalancer service that is deployed on OKE.
To make this happen, the following annotation must be added to the LoadBalancer service:

external-dns.alpha.kubernetes.io/hostname: <fqdn>

Example:

DNS Zone: 5gc.mnc111.mcc111.3gppnetwork.org
Annotation to add to the service: external-dns.alpha.kubernetes.io/hostname: nf.5gc.mnc111.mcc111.3gppnetwork.org

After deploying the service, any network element within the VCN will be able to resolve nf.5gc.mnc111.mcc111.3gppnetwork.org to the Loadbalancer service's IP address.


## Variables

 Name                                                                                                 | Description                                                  | Type     | Default | Required |
| ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ | -------- | ------- | :------: |
| compartment_ocid                                                                                     | The ID of the compartment the stack is deployed in           | `string` | n/a     |    no    |
| region                                                                                               | The region where the landing zone will be deployed in        | `string` | n/a     |    no    |
| tenancy_ocid                                                                                         | The tenancy ocid                                             | `string` | n/a     |    no    |
| cis_level                                                                                            | CIS OCI Benchmark Level of services deployed by the Landing Zone                    | `string` | n/a     |    no    |
| existing_enclosing_compartment_ocid                                                                  | The ocid of the enclosing compartment                        | `string` | n/a     |   yes    |
| net_comp_name                                                                                        | Network compartment name                                     | `string` | n/a     |   yes    |
| sec_comp_name                                                                                        | Security compartment name                                    | `string` | n/a     |    no    |
| app_comp_name                                                                                        | Workload compartment name                                    | `string` | n/a     |    no    |
| db_comp_name                                                                                         | Databse compartment name (not used by the Landing Zone)      | `string` | n/a     |   yes    |
| VCN-name                                                                                             | The name of the VCN                                          | `string` | n/a     |   yes    |
| VCN-CIDR                                                                                             | CIDR blocks of the VCN                                       | `string` | n/a     |    no    |
| K8SLBSubnet-CIDR                                                                                     | CIDR block of the OAM subnet (default load balancer subnet)  | `string` | n/a     |   yes    |
| K8SOperatorSubnet-CIDR                                                                               | CIDR block of operator host subnet (default load balancer subnet)      | `string` | n/a     |    no    |
| K8SAPIEndPointSubnet-CIDR                                                                            | CIDR block of the K8s API subnet                             | `string` | n/a     |    no    |
| K8SNodePoolSubnet-CIDR                                                                               | CIDR block of the node pool subunet                          | `string` | n/a     |   yes    |
| cni_type                                                                                             | type of CNI (flannel or vcn-native)                          | `string` | n/a     |   yes    |
| zone_name                                                                                            | The prefix used to avoid naming conflict                     | `string` | n/a     |    no    |
| ClusterName                                                                                          | The name of the OKE cluster                                  | `string` | n/a     |   yes    |
| kubernetes_version                                                                                   | The Kubernetes version of the OKE cluster                    | `string` | n/a     |    no    |
| multus                                                                                               | Indicates if Multus is enabled                               | `string` | n/a     |    no    |
| nodepool_name                                                                                        | The node pool name                                           | `string` | n/a     |    no    |
| kubernetes_version_np                                                                                | Kubernetes version of the default OKE node pool              | `string` | n/a     |    no    |
| shape                                                                                                | The compute shape of the default node pool's worker nodes    | `string` | n/a     |   yes    |
| Flex_shape_memory                                                                                    | The memory chosen for the default node pool's worker nodes   | `string` | n/a     |    yes   |
| Flex_shape_ocpus                                                                                     | The ocpus chosen for the default node pool's worker nodes    | `string` | n/a     |    yes   |
| node_pool_size                                                                                       | The number of worker nodes within the default node pool      | `string` | n/a     |    no    |
| worker_key                                                                                           | The public key of the worker nodes within the node pool      | `string` | n/a     |    no    |
| bootvolume                                                                                           | The boot volume of the worker nodes within the node pool     | `string` | n/a     |    no    |
| cpu_pinning                                                                                          | Indicates if CPU pinnning is enabled for the dafault node pool | `string` | n/a     |    no    |
| cpu                                                                                                  | Indicates the reserved CPUs for the default node pool, when CPU pinning is enabled  | `string` | n/a     |    no    |
| hp                                                                                                   | Indicates if Hupe Pages (1GB) is enabled for the dafault node pool | `string` | n/a     |    yes   |
| hp_size                                                                                              | Indicates the Hupe Pages (1GB) size for the dafault node pool | `string` | n/a     |    yes   |
| operator_key_public                                                                                  | The public key of the operator host                          | `string` | n/a     |    yes   |
| operator_key_private                                                                                 | The privatekey of the operator host                          | `string` | n/a     |   yes    |
| add_nodepool                                                                                         | Indicates if an additional node pool will be deployed        | `string` | n/a     |    no    |
| addnodepool_name                                                                                     | The name of the additional node pool                         | `string` | n/a     |    no    |
| kubernetes_version_np2                                                                               | Kubernetes version of the additional OKE node pool           | `string` | n/a     |    no    |
| node_pool_size2                                                                                      | The number of worker nodes within the additional node pool   | `string` | n/a     |    no    |
| worker_key2                                                                                          | The public key of the worker nodes within the additional node pools  | `string` | n/a     |    no    |
| Shape2                                                                                               | The compute shape of the additional node pool's worker nodes | `string` | n/a     |   yes    |
| Flex_shape_memory2                                                                                   | The memory chosen for the additional node pool's worker nodes   | `string` | n/a     |    yes   |
| cpu_pinning2                                                                                         | Indicates if CPU pinnning is enabled for the additional node pool | `string` | n/a     |    no    |
| cpu2                                                                                                 | Indicates the reserved CPUs for the additional node pool, when CPU pinning is enabled  | `string` | n/a     |    no    |
| hp2                                                                                                  | Indicates if Hupe Pages (1GB) is enabled for the additional node pool | `string` | n/a     |    yes   |
| hp_size2                                                                                             | Indicates the Hupe Pages (1GB) size for the additional node pool | `string` | n/a     |    yes   |
| enable_cloud_guard                                                                                   | Enable or disable Cloud Guard                                | `string` | n/a     |   yes    |
| operator-image                                                                                       | The OCI of the chosen operator host image                    | `string` | n/a     |    no    |
| service_label                                                                                        | The service label for  the landing zone                      | `string` | n/a     |    no    |

---

### For more information

- [Resource Manager Overview](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm)
- [Bastion Service](https://docs.oracle.com/en-us/iaas/Content/Bastion/Tasks/create-session-managed-ssh.htm)

```

# License

Copyright (c) 2024 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](../../LICENSE) for more details.
