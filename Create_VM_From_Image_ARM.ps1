## Global Config
select-AzureSubscription "MySubscription-PAYG"

$ResGRName = "TestVM1RG"
$location = "North Europe"    # E.G. "West Europe" 

## Storage Config
$StorName = "testvm1"  # Lower-case
$StorType = "Standard_GRS"

## Network Config
$NicName = "TestVM1Nic"
$SubName = "subnet1"
$VNetName = "TestVM2Net"
$VNetAddressPrefix = "172.16.24.0/16"
$VNetSubAddressPrefix = "172.16.24.0/24"

## VM Config
$vmName = "testvm1" # lower-case
$ComputName = "testcomputer" 
$vmSize = "Basic_A1"  # E.G. A5, A6, A7, A8, A9, Basic_A0, Basic_A1, Basic_A2, Basic_A3, ETC ...
$OSDriveName = $vmName + "osDrive"
$SecGRName = $vmName + "NSG"

## Switch Azure Mode To Resource Manager
Switch-AzureMode -Name AzureResourceManager

## Add Resource Group
New-AzureResourceGroup -Name $ResGRName -Location $location

## Create Storage Account
$StorAcc = New-AzureStorageAccount -ResourceGroupName $ResGRName -Name $StorName -Type $StorType -Location $location

## Network
# Create New Virtual Network
$pip = New-AzurePublicIpAddress -Name $NicName -ResourceGroupName $ResGRName -Location $location -AllocationMethod Dynamic # Static
$SubConfig = New-AzureVirtualNetworkSubnetConfig -Name $SubName -AddressPrefix $VNetSubAddressPrefix
$vnet = New-AzureVirtualNetwork -Name $VNetName -ResourceGroupName $ResGRName -Location $location -AddressPrefix $VNetAddressPrefix -Subnet $SubConfig
$nic = New-AzureNetworkInterface -Name $NicName -ResourceGroupName $ResGRName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

# Join To existing VNET (Comment **Create New Virtual Network** config and uncomment 5 lines below)
#$xvnetRG = "ExistingResourceGroup"
#$xvnetName = "ExistingVNetName"
#$pip = New-AzurePublicIpAddress -Name $nicname -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic # Static
#$vnet = Get-AzureVirtualNetwork -ResourceGroupName $xvnetRG -Name $xvnetName
#$nic = New-AzureNetworkInterface -Name $nicname -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

## Setup VM
$VMCred = Get-Credential 

$vm = New-AzureVMConfig -VMName $vmName -VMSize $vmSize
$vm = Set-AzureVMOperatingSystem -VM $vm -Linux -ComputerName $ComputName -Credential $VMCred 

$vm = Add-AzureVMNetworkInterface -VM $vm -Id $nic.Id

$OSDriveUri = "https://testvmrg2112.blob.core.windows.net/$vmName-containerf253fd15-acb5-4405-8519-b8c355982856/osDrive.f253fd15-acb5-4405-8519-b8c355982856.vhd"
$ImageUri = "https://testvmrg2112.blob.core.windows.net/system/Microsoft.Compute/Images/vhds/Capture-osDrive.3343fc9c-5871-4510-9b2e-756dc0e50f64.vhd"
$vm = Set-AzureVMOSDisk -VM $vm -Name "tdr1" -VhdUri $OSDriveUri -CreateOption fromImage -SourceImageUri $ImageUri -Linux  # -Windows

## Create VM in ARM
New-AzureVM -ResourceGroupName $ResGRName -Location $location -VM $vm -Verbose

## Create Security Group And Rules

# Allow SSH Traffic only from MGMT IP
$rule1 = New-AzureNetworkSecurityRuleConfig -Name ssh-rule -Description "Allow SSH" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
    -SourceAddressPrefix "SomeGlobalIP/32" -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 22

# Allow HTTP Traffic 
$rule2 = New-AzureNetworkSecurityRuleConfig -Name web-rule -Description "Allow HTTP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 80

# Create Security Group
New-AzureNetworkSecurityGroup -ResourceGroupName $ResGRName -Location $location -Name $SecGRName -SecurityRules $rule1,$rule2
