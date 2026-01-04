class PluginHeaderEmail : PluginHeader {

    [System.Net.Mail.MailAddressCollection]$Emails


    PluginHeaderEmail() : base(){
        # Default constructor - let base initialize
    }
    PluginHeaderEmail([string]$name, [string]$body) : base($name, $body){
        # Forward to base constructor so ParseBody() is invoked
    }
    

    [void]ParseBody() {
        <#
        .SYNOPSIS
        Parse the header field as needed for the plugin

        .DESCRIPTION
        This plugin will parse email header fields and extract email addresses.
        Splits the body on commas (respecting quoted display names per RFC 5322)
        and adds each address as a MailAddress object to the MailAddressCollection.
        #>
        
        # Initialize the collection
        $this.Emails = [System.Net.Mail.MailAddressCollection]::new()

        # Split on commas while respecting quoted strings (RFC 5322 compliant)
        $addresses = [PluginHeaderEmail]::SplitAddresses($this.Body)
        
        foreach ($addr in $addresses) {
            $trimmed = $addr.Trim()
            
            # Skip empty strings
            if ([string]::IsNullOrWhiteSpace($trimmed)) {
                continue
            }
            
            try {
                # MailAddress constructor handles display name and email address
                # Supports formats: "Display Name" <email@example.com> or just email@example.com
                $mailAddr = [System.Net.Mail.MailAddress]::new($trimmed)
                $this.Emails.Add($mailAddr)
            }
            catch {
                # Skip addresses that cannot be parsed
                continue
            }
        }
    }

    static [string[]]SplitAddresses([string]$addressList) {
        <#
        .SYNOPSIS
        Split an address list on commas, respecting quoted display names

        .DESCRIPTION
        Per RFC 5322, commas can appear inside quoted display names.
        This method splits only on commas that are outside of quoted strings.

        .PARAMETER addressList
        The comma-separated address list to split

        .OUTPUTS
        Array of individual addresses
        #>
        $addresses = @()
        $currentAddress = ""
        $inQuotes = $false
        $chars = $addressList.ToCharArray()
        
        for ($i = 0; $i -lt $chars.Length; $i++) {
            $char = $chars[$i]
            
            # Toggle quote state
            if ($char -eq '"') {
                # Check if it's escaped
                $escapeCount = 0
                $j = $i - 1
                while ($j -ge 0 -and $chars[$j] -eq '\') {
                    $escapeCount++
                    $j--
                }
                
                # If even number of escapes, the quote is not escaped
                if ($escapeCount % 2 -eq 0) {
                    $inQuotes = -not $inQuotes
                }
            }
            
            # Split on comma only if not inside quotes
            if ($char -eq ',' -and -not $inQuotes) {
                if ($currentAddress.Trim().Length -gt 0) {
                    $addresses += $currentAddress.Trim()
                }
                $currentAddress = ""
            }
            else {
                $currentAddress += $char
            }
        }
        
        # Add the last address
        if ($currentAddress.Trim().Length -gt 0) {
            $addresses += $currentAddress.Trim()
        }
        
        return $addresses
    }


    static [Array]fieldNames(){
        <#
        .SYNOPSIS
        Return a string of header fields this plugin works for.
        #>
        $names = @(
            "Sender"
            "From"
            "To"
            "Cc"
            "Bcc"
            "Delivered-To"
            "X-Original-From"
            "Reply-To"
        )
        return $names
    }

}

[HeaderFieldPlugins]::GetInstance().RegisterPlugin([PluginHeaderEmail])
