function Get-DnsRecord {
    <#
    .SYNOPSIS
    Displays basic information about an EML file.

    .DESCRIPTION
    Parses an EML file and displays sender, recipient, subject, and other key details.

    .PARAMETER Path
    The file path to the EML file.

    .EXAMPLE
    Get-EmlInfo -Path "C:\emails\message.eml"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain,

        [Parameter(Mandatory = $false)]
        [ValidateSet('A', 'AAAA', 'CNAME', 'MX', 'TXT', 'SRV', 'NS', 'PTR')]
        [string]$RecordType = 'A',

        [Parameter(Mandatory = $false)]
        [string]$DnsServer = $null
    )

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $process = [System.Diagnostics.Process]::new()
    
    
    if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
        # Windows: use nslookup
        Write-Debug "Using Resolve-DnsName on Windows"

        $psi.FileName = "Resolve-DnsName"
        $psi.ArgumentList.Add("-Type=${RecordType}")
        $psi.ArgumentList.Add("-Name ${Domain}")
        if($DnsServer) {
            $psi.ArgumentList.Add("-Server ${DnsServer}")
        }

        $result = nslookup -type=$RecordType $Domain $DnsServer 2>$null
        $txtRecords = $result | Where-Object { $_ -match '".*"' } | ForEach-Object {
            if ($_ -match '"(.*)"') { $matches[1] }
        }
    }
    else {
        # Linux/Mac: use dig if available, otherwise nslookup
        if (Get-Command dig -ErrorAction SilentlyContinue) {
            Write-Debug "Using dig on Linux/Mac"

            $psi.FileName = "dig"
            $psi.ArgumentList.Add("+short")
            $psi.ArgumentList.Add("${RecordType}")
            $psi.ArgumentList.Add("${Domain}")
            if($DnsServer) {
                $psi.ArgumentList.Add("@${DnsServer}")
            }

            $result = dig +short $RecordType $Domain $(if ($DnsServer) { "@$DnsServer" } else { "" }) 2>$null
            $txtRecords = $result | ForEach-Object { $_.Trim('"') }
        } else {
            Write-Debug "Using nslookup on Linux/Mac"
            
            $psi.FileName = "nslookup"
            $psi.ArgumentList.Add("-type=${RecordType}")
            $psi.ArgumentList.Add("${Domain}")
            if($DnsServer) {
                $psi.ArgumentList.Add("${DnsServer}")
            }

            $result = nslookup -type=$RecordType $Domain 2>$null
            $txtRecords = $result | Where-Object { $_ -match '".*"' } | ForEach-Object {
                if ($_ -match '"(.*)"') { $matches[1] }
            }
        }
    }

    
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $process.StartInfo = $psi
    $process.Start() | Out-Null

    $output = $process.StandardOutput.ReadToEnd()
    $errors = $process.StandardError.ReadToEnd()

    $process.WaitForExit()

    Write-Output $output
    Write-Error $errors

    
    return $txtRecords
}
