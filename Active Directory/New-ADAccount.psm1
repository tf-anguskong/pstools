<#
.Synopsis
   New-ADUser with a twist
.DESCRIPTION
    PREREQUISITES:
        Active Directory Powershell Module Installed (Include when you install RSAT Tools)
        Appropriate permissions set on Exchange Server (If you want to provision mailbox)

    DEFAULT BEHAVIOR:

.EXAMPLE

.EXAMPLE

#>



function New-ADAccount {
    param (
        [Parameter(Mandatory)]$FirstName,
        $MiddleName,
        [Parameter(Mandatory)]$LastName,
        [Parameter(Mandatory)]$RequestID, # Used to append to the ticket in Service Desk
        [Parameter(Mandatory)]$Location, # LA,PTL,SEA, etc etc
        $EmployeeNumber
    )
    function Update-Request {
        param (
            [string]$RequestID,
            [array]$groups,
            $username
        )

        $body = "<p>The account <strong>$username</strong> has been created."
        $body += "<p>They have been added to the following groups; please review.</p>"
        $body += foreach ($g in $groups) {
            $g = $g.Split(",")[0].TrimStart("CN=")
            "<p>"+$g+"</p>"
        }

        Send-MailMessage -Subject "[Request ID :##$RequestID##] : New User Made -- TESTING " -SmtpServer webmail.triplebcorp.com -To "techsupport@charliesproduce.com" -BodyAsHtml $body -From "ADPowershell@triplebcorp.com"

    }
    #Determines the base groups based off location specified. 
    function Determine-Groups {
        param (
            $Location
        )
        
        $groups = @()
        # Determines which groups should be used. 
        
        $SEA = @("Seattle","SEA")
        $AK = @("Anchorage","Alaska","ANC")
        $SLC = @("Salt Lake City","SLC","Muir")
        $LA = @("California","LA","Irwindale","Los Angeles")
        $PTL = @("Portland","Clackamas","PTL")
        $SPO = @("Spokane","SPO")
        $BOI = @("Boise","BOI")
        $CPFresh = @("CPFresh","Southpark","SP")

        if ($SEA -contains $Location) {
            $groups += "CN=Everyone - Seattle,OU=Recipients,DC=fleming,DC=systems"
            $groups += "CN=Charlies,OU=SeattleUsers,OU=Seattle,DC=fleming,DC=systems"
        }
        if ($BOI -contains $Location) {
            $groups += "CN=BoiseUsers,OU=BoiseGroups,OU=Boise,DC=fleming,DC=systems"
            $groups += "CN=CN=Everyone - Boise,OU=Recipients,DC=fleming,DC=systems"
        }
        if ($AK -contains $Location) {
            $groups += "CN=AnchorageUsers,OU=AnchorageGroups,OU=Anchorage,DC=fleming,DC=systems"
            $groups += "CN=Everyone - Anchorage,OU=Recipients,DC=fleming,DC=systems"
        }
        if ($SLC -contains $Location) {
            $groups += "CN=Everyone - SaltLakeCity,CN=Users,DC=fleming,DC=systems"
            $groups += "CN=SaltLakeCity Users,OU=SaltLakeCityGroups,OU=SaltLakeCity,DC=fleming,DC=systems"
        }
        if ($LA -contains $Location) {
            $groups += "CN=Everyone - LosAngeles,OU=Recipients,DC=fleming,DC=systems"
            $groups += "CN=LosAngeles Users,OU=LosAngelesGroups,OU=LosAngeles,DC=fleming,DC=systems"
        }
        if ($PTL -contains $Location) {
            $groups += "CN=Everyone - Portland,OU=Recipients,DC=fleming,DC=systems"
            $groups += "CN=Portland Users,OU=PortlandGroups,OU=Portland,DC=fleming,DC=systems"
        }
        if ($SPO -contains $Location) {
            $groups += "CN=Spokane Users,OU=SpokaneGroups,OU=Spokane,DC=fleming,DC=systems"
            $groups += "CN=Everyone - Spokane,OU=Recipients,DC=fleming,DC=systems"
        }
        if ($CPFresh -contains $Location) {
            $groups += "CN=CPF Main,OU=Recipients,DC=fleming,DC=systems"
            $groups += "CN=CPFresh,OU=CPFreshGroups,OU=CP Fresh,DC=fleming,DC=systems"
            $groups += "CN=Everyone - CPFresh,OU=Recipients,DC=fleming,DC=systems"
        }

        $groups += "CN=Umbrella Medium Restriction Internet,CN=Users,DC=fleming,DC=systems"

        return $groups
    }
    function Check-Username {
        param (
            $FirstName,
            $MiddleName,
            $LastName
        )

        $FirstCombo = $FirstName + $LastName[0]
        $SecondCombo = $FirstName[0] + $LastName
        if($MiddleName){$ThirdCombo = $FirstName[0] + $MiddleName[0] + $LastName}

        $check = [bool](Get-ADUser -Filter {SamAccountName -eq $FirstCombo})
        if($check -eq $true){
            $check = [bool](Get-ADUser -Filter {SamAccountName -eq $SecondCombo})
            if ($check -eq $true) {
                if(!$MiddleName){Write-Host "You need to specify a Middle Name (or middle inital) for this User"}
                if($MiddleName){
                    $username = $ThirdCombo; return $username.ToString().ToLower()
                }
            }
            else {
                $username = $SecondCombo
                return $username.ToString().ToLower()
            }
        }
        else {
            $username = $FirstCombo
            return $username.ToString().ToLower()
        }  
    }
    function Get-BaseOU {
        param (
            $Location
        )
        
        $ht = @{
            LA = "OU=LosAngelesUsers,OU=LosAngeles,DC=fleming,DC=systems"
            SEA = "OU=Seattle,DC=fleming,DC=systems"
            PTL = "OU=PortlandUsers,OU=Portland,DC=fleming,DC=systems"
            SPO = "OU=SpokaneUsers,OU=Spokane,DC=fleming,DC=systems"
            ANC = "OU=AnchorageUsers,OU=Anchorage,DC=fleming,DC=systems"
            BOI = "OU=BoiseUsers,OU=Boise,DC=fleming,DC=systems"
            SLC = "OU=SaltLakeCityUsers,OU=SaltLakeCity,DC=fleming,DC=systems"
            TEST = "OU=Test Tyler,OU=IT,DC=fleming,DC=systems"
        }

        $OU = $ht.$location
        return $OU

    }
    #Create Username, tries <first name + last initial> first, if that doesn't work <first initial + last name>, if THAT doesn't work <first initial + middle intial + last name>
    if (!$MiddleName){$username = Check-Username -FirstName $FirstName -LastName $LastName}
    if ($MiddleName) {$username = Check-Username -FirstName $FirstName -MiddleName $MiddleName -LastName $LastName}
    #Get Base OU that account will be placed into
    $OUPath = Get-BaseOU -Location $Location
    $DefaultPassword = ConvertTo-SecureString -String "asdf1234" -AsPlainText -Force

    if(!$EmployeeNumber){New-ADUser -Name ($FirstName+" "+$LastName) -GivenName $FirstName -Surname $LastName -SamAccountName $username -Enabled $true -ChangePasswordAtLogon $true -Path $OUPath -AccountPassword $DefaultPassword -UserPrincipalName "$username@charliesproduce.com"}
    if($EmployeeNumber){New-ADUser -Name ($FirstName+" "+$LastName) -GivenName $FirstName -Surname $LastName -SamAccountName $username -Enabled $true -ChangePasswordAtLogon $true -Path $OUPath -AccountPassword $DefaultPassword -UserPrincipalName "$username@charliesproduce.com" -EmployeeNumber $EmployeeNumber}

    #Returns the Office Location and groups
    $groups = Determine-Groups -Location $Location
    $groups | ForEach-Object {Add-ADGroupMember -Identity $_ -Members $username}

    Update-Request -RequestID $RequestID -groups $groups -username $username
}


