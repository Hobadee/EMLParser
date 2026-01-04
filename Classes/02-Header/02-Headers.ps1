class Headers : System.Collections.Generic.List[PSObject]{
    <#
    .SYNOPSIS
    Class to hold all Header Fields

    .DESCRIPTION
    Used by the Imf class to hold all header fields
    #>


    [PluginHeader]getHeaderByName([string]$name){
        <#
            .SYNOPSIS
            Returns the *FIRST* header matching $name

            .PARAMETER name
            The header field name to search for

            .OUTPUTS
            A PSObject containing the first header with the specified name, or $null if not found
        #>

        foreach($header in $this){
            if($header.getName() -eq $name){
                return $header
            }
        }
        return $null
    }


    [PSObject]getHeadersByName([string]$name){
        <#
            .SYNOPSIS
            Returns a List object of all headers matching a name

            .PARAMETER name
            The header field name to filter by

            .OUTPUTS
            A List of PSObject containing all headers with the specified name

            .NOTES
            This is a convenience overload that does anchored matching
        #>
        return $this.getHeadersByName($name, $true)
    }
    [PSObject]getHeadersByName([string]$name, [bool]$anchorMatch){
        <#
            .SYNOPSIS
            Returns a List object of all headers matching a name

            .PARAMETER name
            The header field name to filter by

            .PARAMETER anchorMatch
            If $true, the name will be anchored for "exact" matching (Wildcards still allowed inside)
            ie: "^$name$"
            This will default to true via a convenience overload

            .OUTPUTS
            A List of PSObject containing all headers with the specified name
        #>

        $rtnArray = [System.Collections.Generic.List[PSObject]]::new()

        if($anchorMatch){
            $name = "^$name$"
        }

        foreach($header in $this){
            if($header.getName() -Match $name){
                $rtnArray.Add($header)
            }
        }
        
        return $rtnArray
    }


    [PSObject]getHeadersByPlugin([string]$pluginName){
        <#
            .SYNOPSIS
            Returns a List object of all headers matching a plugin type

            .PARAMETER pluginName
            The plugin type name to filter headers by

            .OUTPUTS
            A List of PSObject containing all headers of the specified plugin type
        #>

        $rtnArray = [System.Collections.Generic.List[PSObject]]::new()

        foreach($header in $this){
            if($header.GetType().Name -eq $pluginName){
                $rtnArray.Add($header)
            }
        }
        
        return $rtnArray
    }


    [Headers]parseHeaders([string]$rawHeaders){
        <#
        .SYNOPSIS
        Parse raw header data into HeaderField objects

        .DESCRIPTION
        This method parses the provided raw header string into individual
        HeaderField objects (or PluginHeaderField objects as appropriate) and
        adds them to the Headers collection.

        .PARAMETER rawHeaders
        The raw header string to parse

        .OUTPUTS
        The Headers object with parsed HeaderField objects added

        .NOTES
        This method uses a regex to identify header lines and then
        utilizes the HeaderFieldFactory to create appropriate header objects.
        #>

        $search = '^(?<Name>[^:]+):(?<Body>.*)$'
        $regex = [regex]::new($search, [System.Text.RegularExpressions.RegexOptions]::Multiline)

        $matches = @($regex.Matches($rawHeaders))
        Write-Debug("Headers.parseHeaders() - Headers found: $($matches.Count)")

        foreach ($match in $matches){
            $name = $match.Groups["Name"].Value
            $body = $match.Groups["Body"].Value
            try{
                $hf = [HeaderFieldFactory]::CreateHeaderField($name, $body)
                $this.Add($hf)
                Write-Debug("Headers.parseHeaders() - Adding plugin '$($hf.GetType())' for header '$($hf.getName())'")
            }
            catch {
                Write-Error("Failed to add header field: $_")
                continue
            }
        }

        return $this
    }



}
