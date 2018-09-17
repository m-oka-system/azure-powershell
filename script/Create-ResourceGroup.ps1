$rg = "ResourceGroup"
$location = "japanwest"
New-AzureRmResourceGroup -Location $location -Name $rg
Get-AzureRmResourceGroup -Name $rg