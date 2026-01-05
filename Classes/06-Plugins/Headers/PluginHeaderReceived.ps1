class PluginHeaderReceived : PluginHeader {

    [string]$From
    [string]$By
    [Timestamp]$Timestamp
    [string]$Id
    [string]$IdType


    PluginHeaderReceived() : base(){
        # Default constructor - let base initialize
    }
    PluginHeaderReceived([string]$name, [string]$body) : base($name, $body){
        # Forward to base constructor so ParseBody() is invoked
    }
    

    [void]ParseBody() {
        <#
        .SYNOPSIS
        Parse the header field as needed for the plugin

        .DESCRIPTION
        Extract from, by, id, idType, and timestamp from a "Received" header field

        .NOTES
        RFC 5322 defines the Received header format as:
        Received: from <sending-host> by <receiving-host> with <protocol> id <id>; <timestamp>
        #>

        try {
            # Extract "from" field - everything after "from" up to "by"
            $fromMatch = [regex]::Match($this.Body, 'from\s+([^\s]+)', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            if ($fromMatch.Success) {
                $this.From = $fromMatch.Groups[1].Value.Trim()
                Write-Debug("Received.ParseBody - From: $($this.From)")
            }

            # Extract "by" field - everything after "by" up to next keyword
            $byMatch = [regex]::Match($this.Body, 'by\s+([^\s]+)', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            if ($byMatch.Success) {
                $receiver = $byMatch.Groups[1].Value.Trim()
                $receiver = $receiver -replace '[;,]+$',''  # Remove trailing semicolon or comma
                $this.By = $receiver
                Write-Debug("Received.ParseBody - By: $($this.By)")
            }

            # Extract "with" field (protocol/idType) - everything after "with" up to next keyword
            $withMatch = [regex]::Match($this.Body, 'with\s+(\w+)', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            if ($withMatch.Success) {
                $this.IdType = $withMatch.Groups[1].Value.Trim()
                Write-Debug("Received.ParseBody - IdType: $($this.IdType)")
            }

            # Extract "id" field - everything after "id" up to semicolon or end
            $idMatch = [regex]::Match($this.Body, 'id\s+([^;\s]+)', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            if ($idMatch.Success) {
                $this.Id = $idMatch.Groups[1].Value.Trim()
                Write-Debug("Received.ParseBody - Id: $($this.Id)")
            }

            # Extract timestamp - everything after the last semicolon
            $timestampMatch = [regex]::Match($this.Body, ';\s*(.+)$')
            if ($timestampMatch.Success) {
                $timestampString = $timestampMatch.Groups[1].Value.Trim()
                Write-Debug("Received.ParseBody - Timestamp string: $timestampString")
                
                # Try to create Timestamp object if the class exists
                if ([appdomain]::CurrentDomain.GetAssemblies().GetTypes() | Where-Object { $_.Name -eq 'Timestamp' }) {
                    $this.Timestamp = [Timestamp]::new($timestampString)
                } else {
                    # Fallback: store as string if Timestamp class doesn't exist yet
                    Write-Debug("Timestamp class not found; storing as string")
                    $this.Timestamp = $timestampString
                }
            }
        }
        catch {
            Write-Debug("Error parsing Received header: $_")
            throw
        }
    }

    static [string[]]fieldNames() {
        $names = @(
            "Received"
            "X-Received"
        )
        return $names
    }
}

[HeaderFieldPlugins]::GetInstance().RegisterPlugin([PluginHeaderReceived])
