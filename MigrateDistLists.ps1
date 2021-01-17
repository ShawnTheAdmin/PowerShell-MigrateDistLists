<#
.SYNOPSIS
Module that will migrate a list of distribution groups from on-premises Exchange to Office365. 
.DESCRIPTION
Module that loops over a list of on-premises distribution lists and recreates them in 365. The module will recreate the group as groupname-TEMP@domain.com and copy over group membership. The script expects there to be one grou per line with no header.
#>

$Groups = get-content $env:userprofile\desktop\groups.txt

foreach ($Group in $Groups) {
    
    $Domain = (Get-DistributionGroup $Group).PrimarySMTPAddress.split("@")
    $TempName = "$Group-TEMP"
    $SourceMembers = (Get-DistributionGroupMember $Group).PrimarySMTPAddress

    if ($Group -match " ") {

        $GroupJoined = $Group -replace (' ')
        $SourceSmtpAddress = "$GroupJoined@$($Domain[1])"
        $TempSmtpAddress = "$GroupJoined-TEMP@$($Domain[1])" 

    } else {

        $SourceSmtpAddress = "$Group@$($Domain[1])"
        $TempSmtpAddress = "$Group-TEMP@$($Domain[1])" 

    }

    New-DistributionGroup -Name $TempName -Type "Distribution" -PrimarySmtpAddress $TempSmtpAddress

    foreach ($Member in $SourceMembers) { 
        
        Add-DistributionGroupMember -Identity $TempName -Member $Member

    }

}