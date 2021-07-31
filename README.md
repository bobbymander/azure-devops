# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, we created a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.  We started with development tool setup and Azure account setup.  The tools we used include the Azure command line interface, packer for building customized images, and terraform for deploying to Azure.  We also used the Azure Portal to setup resource groups and verify policies.  We encountered some gotchas in the project such as creating service principals and setting proper environment variables.  

Once all was working, we could deploy our new web server in a matter of minutes and destroy the same very quickly as well.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
1. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
1. Install [Packer](https://www.packer.io/downloads)
1. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

1.  Create a resource group using the Portal.  Navigate to the resource groups module and click + to add a resource group.

2.  Create  a service principal as below:

* `az ad sp create-for-rbac --name bobby-sp`
* `az role assignment create --assignee a1e4a397-2239-461b-bc4d-2b1aa0652775 --role Contributor`

3.  Setup your environment variables as below:

* `export ARM_CLIENT_ID=a1e4a397-2239-461b-bc4d-2b1aa0652775`
* `export ARM_CLIENT_SECRET=9mCiQP3G5~q-zbpoTE2~l5KyveBL1Ot0c-`
* `export ARM_SUBSCRIPTION_ID=9ae58088-2eab-4683-8358-02e573fca8ab`
* `export ARM_TENANT_ID=e48b486a-777d-49eb-9ae0-5d33b396cc2e`

All these are needed to run packer and terraform properly.

4.  Run packer as follows to create the server image (this will take time):

`packer build server.json`

5.  Run terraform as follows to deploy the web server (the last step will take time):

  #### this ensures the Azure plugin is installed
  `terraform init`

  #### this ensures that the resource group is not created again as we've already created it
  `terraform import azurerm_resource_group.main /subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg`

  #### this creates the plan to create the deployment
  `terraform plan -out solution.plan`

  #### this deploys the web server.  the export fixes a problem in finding the right resource group
  `export MSYS_NO_PATHCONV=1`
  `terraform apply solution.plan`

  #### this destroys everything so we are not continually billed!
  `terraform destroy`

### Customization

In order to customize this web server for use you can edit the vars.tf file and change the entries there.  There are entries for:
  * -prefix:  naming prefix to use for all the resources we create
  * -purpose:  tag used on all resources we create as all resources need tags due to our policy
  * -location:  the Azure location we are using for our deployment
  * -numVms:  the number of VMs you want to deploy for redundancy
  
### Output from packer and terraform
The lengthy commands for packer and terraform take on the order of 5-10mins to run.  Some sample output is below:

bmand@DESKTOP-4S3G362 MINGW64 ~/src/nd082-Azure-Cloud-DevOps-Starter-Code/C1 - Azure Infrastructure Operations/project/starter_files (master)
$ packer build server.json
azure-arm: output will be in this color.

==> azure-arm: Running builder ...
==> azure-arm: Getting tokens using client secret
==> azure-arm: Getting tokens using client secret
    azure-arm: Creating Azure Resource Manager (ARM) client ...
==> azure-arm: WARNING: Zone resiliency may not be supported in East US, checkout the docs at https://docs.microsoft.com/en-us/azure/availability-zones/
==> azure-arm: Creating resource group ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-abw5sncgy2'
==> azure-arm:  -> Location          : 'East US'
==> azure-arm:  -> Tags              :
==> azure-arm:  ->> environment : project
==> azure-arm: Validating deployment template ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-abw5sncgy2'
==> azure-arm:  -> DeploymentName    : 'pkrdpabw5sncgy2'
==> azure-arm: Deploying deployment template ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-abw5sncgy2'
==> azure-arm:  -> DeploymentName    : 'pkrdpabw5sncgy2'
==> azure-arm:
==> azure-arm: Getting the VM's IP address ...
==> azure-arm:  -> ResourceGroupName   : 'pkr-Resource-Group-abw5sncgy2'
==> azure-arm:  -> PublicIPAddressName : 'pkripabw5sncgy2'
==> azure-arm:  -> NicName             : 'pkrniabw5sncgy2'
==> azure-arm:  -> Network Connection  : 'PublicEndpoint'
==> azure-arm:  -> IP Address          : '40.71.121.255'
==> azure-arm: Waiting for SSH to become available...
==> azure-arm: Connected to SSH!
==> azure-arm: Provisioning with shell script: C:\Users\bmand\AppData\Local\Temp\packer-shell581309295
==> azure-arm: + echo Hello, World!
==> azure-arm: + nohup busybox httpd -f -p 80
==> azure-arm: Querying the machine's properties ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-abw5sncgy2'
==> azure-arm:  -> ComputeName       : 'pkrvmabw5sncgy2'
==> azure-arm:  -> Managed OS Disk   : '/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/pkr-Resource-Group-abw5sncgy2/providers/Microsoft.Compute/disks/pkrosabw5sncgy2'
==> azure-arm: Querying the machine's additional disks properties ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-abw5sncgy2'
==> azure-arm:  -> ComputeName       : 'pkrvmabw5sncgy2'
==> azure-arm: Powering off machine ...
==> azure-arm:  -> ResourceGroupName : 'pkr-Resource-Group-abw5sncgy2'
==> azure-arm:  -> ComputeName       : 'pkrvmabw5sncgy2'
==> azure-arm: Capturing image ...
==> azure-arm:  -> Compute ResourceGroupName : 'pkr-Resource-Group-abw5sncgy2'
==> azure-arm:  -> Compute Name              : 'pkrvmabw5sncgy2'
==> azure-arm:  -> Compute Location          : 'East US'
==> azure-arm:  -> Image ResourceGroupName   : 'bobby-web-project-rg'
==> azure-arm:  -> Image Name                : 'BobbyPackerImage'
==> azure-arm:  -> Image Location            : 'East US'
==> azure-arm: Removing the created Deployment object: 'pkrdpabw5sncgy2'
==> azure-arm:
==> azure-arm: Cleanup requested, deleting resource group ...
==> azure-arm: Resource group has been deleted.
Build 'azure-arm' finished after 7 minutes 38 seconds.

==> Wait completed after 7 minutes 38 seconds

==> Builds finished. The artifacts of successful builds are:
--> azure-arm: Azure.ResourceManagement.VMImage:

OSType: Linux
ManagedImageResourceGroupName: bobby-web-project-rg
ManagedImageName: BobbyPackerImage
ManagedImageId: /subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Compute/images/BobbyPackerImage
ManagedImageLocation: East US

bmand@DESKTOP-4S3G362 MINGW64 ~/src/nd082-Azure-Cloud-DevOps-Starter-Code/C1 - Azure Infrastructure Operations/project/starter_files (master)
$ terraform apply solution.plan
azurerm_availability_set.main: Creating...
azurerm_managed_disk.main: Creating...
azurerm_virtual_network.main: Creating...
azurerm_public_ip.main: Creating...
azurerm_network_security_group.main: Creating...
azurerm_availability_set.main: Creation complete after 2s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Compute/availabilitySets/bobby-aset]
azurerm_public_ip.main: Creation complete after 3s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/publicIPAddresses/bobby-publicIp]
azurerm_lb.main: Creating...
azurerm_managed_disk.main: Creation complete after 4s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Compute/disks/bobby-managed-disk]
azurerm_lb.main: Creation complete after 3s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/loadBalancers/bobby-lb]
azurerm_lb_backend_address_pool.main: Creating...
azurerm_virtual_network.main: Creation complete after 6s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/virtualNetworks/bobby-network]
azurerm_subnet.internal: Creating...
azurerm_network_security_group.main: Creation complete after 6s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/networkSecurityGroups/bobby-nsg]
azurerm_lb_backend_address_pool.main: Creation complete after 1s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/loadBalancers/bobby-lb/backendAddressPools/AddressPool]
azurerm_subnet.internal: Creation complete after 4s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/virtualNetworks/bobby-network/subnets/internal]
azurerm_network_interface.main[1]: Creating...
azurerm_network_interface.main[0]: Creating...
azurerm_network_interface.main[1]: Creation complete after 2s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/networkInterfaces/bobby-1-nic]
azurerm_network_interface.main[0]: Creation complete after 3s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/networkInterfaces/bobby-0-nic]
azurerm_network_interface_backend_address_pool_association.main[0]: Creating...
azurerm_network_interface_backend_address_pool_association.main[1]: Creating...
azurerm_linux_virtual_machine.main[1]: Creating...
azurerm_linux_virtual_machine.main[0]: Creating...
azurerm_network_interface_backend_address_pool_association.main[1]: Creation complete after 1s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/networkInterfaces/bobby-1-nic/ipConfigurations/internal|/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/loadBalancers/bobby-lb/backendAddressPools/AddressPool]
azurerm_network_interface_backend_address_pool_association.main[0]: Creation complete after 2s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/networkInterfaces/bobby-0-nic/ipConfigurations/internal|/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Network/loadBalancers/bobby-lb/backendAddressPools/AddressPool]
azurerm_linux_virtual_machine.main[0]: Still creating... [10s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [10s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [40s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [40s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m10s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m40s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m40s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [1m50s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [1m50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [2m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [2m10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m10s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [2m20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m20s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [2m30s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [2m40s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m40s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [2m50s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [2m50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [3m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [3m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [3m10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [3m10s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [3m20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [3m20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [3m30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [3m30s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [3m40s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [3m40s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [3m50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [3m50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [4m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [4m0s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [4m10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [4m10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [4m20s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [4m20s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [4m30s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [4m30s elapsed]
azurerm_linux_virtual_machine.main[1]: Still creating... [4m40s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [4m40s elapsed]
azurerm_linux_virtual_machine.main[1]: Creation complete after 4m50s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Compute/virtualMachines/bobby-1-vm]
azurerm_linux_virtual_machine.main[0]: Still creating... [4m50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [5m0s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [5m10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [5m20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [5m30s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [5m40s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [5m50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [6m0s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [6m10s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [6m20s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [6m30s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [6m40s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [6m50s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [7m1s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [7m11s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [7m21s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [7m31s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [7m41s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [7m51s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [8m1s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [8m11s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [8m21s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [8m31s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [8m41s elapsed]
azurerm_linux_virtual_machine.main[0]: Still creating... [8m51s elapsed]
azurerm_linux_virtual_machine.main[0]: Creation complete after 8m51s [id=/subscriptions/9ae58088-2eab-4683-8358-02e573fca8ab/resourceGroups/bobby-web-project-rg/providers/Microsoft.Compute/virtualMachines/bobby-0-vm]

Apply complete! Resources: 14 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

