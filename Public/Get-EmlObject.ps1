function Get-EmlObject {
    <#
    .SYNOPSIS
    Returns an IMF object from an EML file.

    .DESCRIPTION
    Parses an EML file and returns an IMF object.
    
    Note: Due to PowerShell's enumeration behavior, you need to reference the "Imf"
    property of the returned object to access the actual Imf instance.

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
            
            # Supidity to return an *ACTUAL* "Imf" object
            # PWSH is "enumerating" the object into a base object
            # Downside to this stupid: We need to reference: $imf.Imf.
            return ,([pscustomobject]@{ Imf = $imf })
        }
        catch {
            Write-Error "Failed to parse EML file: $_"
        }
    }
}
