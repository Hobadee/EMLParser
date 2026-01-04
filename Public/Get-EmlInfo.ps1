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

            # Get the domain from the From header
            $fromHeader = $imf.Headers.getHeaderByName('From')
            $domain = $fromHeader.Emails[0].Host

            # Query DMARC TXT record
            $dmarc = [System.Net.Dns]::GetHostByName("_dmarc.$domain")
            
            [PSCustomObject]@{
                From           = $imf.Headers.getHeaderByName('From')
                To             = $imf.Headers.getHeaderByName('To')
                Cc             = $imf.Headers.getHeaderByName('Cc')
                DMARC          = $dmarc
                Subject        = $imf.Headers.getHeaderByName('Subject').getBody()
                Date           = $imf.Headers.getHeaderByName('Date').getBody()
                MessageID      = $imf.Headers.getHeaderByName('Message-ID').getBody()
                MessageHops    = ($imf.Headers.getHeadersByName('Received')).Count
                BodySize       = $imf.Body.Length
            }
        }
        catch {
            Write-Error "Failed to parse EML file: $_"
        }
    }
}
