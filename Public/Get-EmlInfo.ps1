function Get-EmlInfo {
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
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path
    )

    process {
        try {
            $imf = [ImfFactory]::CreateImfFromFile($Path)
            
            [PSCustomObject]@{
                Imf    = $imf
            }
        }
        catch {
            Write-Error "Failed to parse EML file: $_"
        }
    }
}
