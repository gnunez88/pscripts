<#
    To use it you have to import it:
    PS C:\> . .\Get-Apps.ps1
    And then execute it.
    Examples:
    - Get applications and write them into "test.txt"
        Get-Apps -FileName "test.txt"
    - Get applications and write them into "test.csv" in CSV format
        Get-Apps -FileName "test.csv" -Csv
#>
function Get-Apps {
    Param (
        [Parameter(Mandatory=$true, HelpMessage="The output filename")][String]$FileName,
        [Switch]$CSV
    )

    $source1 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*
    $source2 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
    $source3 = Get-WmiObject -Class Win32_Product

    $list1 = $source1 | Select-Object -Property DisplayName, DisplayVersion, Publisher | Where-Object {$_.DisplayName -ne $null}
    $list2 = $source2 | Select-Object -Property DisplayName, DisplayVersion, Publisher | Where-Object {$_.DisplayName -ne $null}
    $list3 = $source3 | Select-Object -Property Name, Version, Vendor | Where-Object {$_.Name -ne $null}

    #$apps1 = ($list1 | Format-Table -HideTableHeaders | Out-String -Stream | Where-Object {$_ -ne ""})
    #$apps2 = ($list2 | Format-Table -HideTableHeaders | Out-String -Stream | Where-Object {$_ -ne ""})
    #$apps3 = ($list3 | Format-Table -HideTableHeaders | Out-String -Stream | Where-Object {$_ -ne ""})

    $apps1 = For ($i=0; $i -lt $list1.Length; $i++) {
        $list1[$i].DisplayName + " --- " + $list1[$i].DisplayVersion + " --- " + $list1[$i].Publisher
    }
    $apps2 = For ($i=0; $i -lt $list2.Length; $i++) {
        $list2[$i].DisplayName + " --- " + $list2[$i].DisplayVersion + " --- " + $list2[$i].Publisher
    }
    $apps3 = For ($i=0; $i -lt $list3.Length; $i++) {
        $list3[$i].Name + " --- " + $list3[$i].Version + " --- " + $list3[$i].Vendor
    }

    $apps = $apps1, $apps2, $apps3 | Out-String -Stream | Sort-Object -Unique

    if ($PSBoundParameters.Keys.Contains("CSV")) {
        $apps = $apps | ConvertFrom-String -Delimiter " --- " -PropertyNames "Name", "Version", "Vendor"
        $apps | Export-Csv -Path $FileName -NoTypeInformation
    } else {
        Set-Content $FileName $apps
    }
}
