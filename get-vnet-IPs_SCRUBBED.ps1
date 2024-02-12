# Opens default browser for OAUTH
Connect-AzAccount

# Sets Subscription to Platform Landing Zone
Set-AzContext -SubscriptionName $env:AzureSubscription

# Get all VNets
$vnets = Get-AzVirtualNetwork 

# Initialize an empty array for the results
$results = @()

# Enmurate all VNets in the provided Subscription, then enumerate all subnets inside those VNets
foreach ($vnet in $vnets) {

    foreach ($subnet in $vnet.Subnets) {

        # Gets all NIC interfaces and stores their PrivateAddress values in the $results dictionary
        $usedIPs = (Get-AzNetworkInterface).IpConfigurations | Where-Object { $_.Subnet.Id -eq $subnet.Id } | Select-Object -ExpandProperty PrivateIpAddress

        # Instantiates a dictionary object with the relavant data pulled from the VNets/subnets/privateAddresses
        $results += [PSCustomObject]@{
            "VNetName"              = $vnet.Name
            "VNetAddressSpace"      = ($vnet.AddressSpace.AddressPrefixes -join ', ')
            "SubnetName"            = $subnet.Name
            "SubnetAddressSpace"    = $subnet.AddressPrefix
            "UsedIPs"               = ($usedIPs -join ', ')
        }
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "VNetIPReport.csv" -NoTypeInformation
