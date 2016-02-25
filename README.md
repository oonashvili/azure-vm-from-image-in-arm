# Creating Linux VM in Azure from generalized image in ARM
---

Requirement : Template of a Linux virtual machine

Documentation at : https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-capture-image-resource-manager/
> **Note:** 
> You Should use [AZURE CLI](https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/)
 for it.

### Script Usage

Script is very simple for usage, you should update only few variables to suiting your needs. *e.g.*

- **ResourceGroupName** - `$ResGRName = "TestVM1RG"`
- **Location** - `$location = "North Europe"`
-  **Storage Name** - `$StorName = "testvm1"`
- **Storage Type** - `$StorType = "Standard_GRS"`
- **Virtual Machine Name** - `$vmName = "testvm1"`
- **Computer Name** - `$ComputName = "testcomputer"`
- **Virtual Machine Size** - `$vmSize = "Basic_A1"`
- **OS Drive Name** - `$OSDriveName = $vmName + "osDrive"`
- **Network Security Group Name** - `$SecGRName = $vmName + "NSG"`


> **Note:** 
> This script works with Azure Powershell version 0.9.8
