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
        #>

        $rtnArray = [System.Collections.Generic.List[PSObject]]::new()

        foreach($header in $this){
            if($header.getName() -eq $name){
                $rtnArray.Add($header)
            }
        }
        
        return $rtnArray
    }


    [Headers]parseHeaders([string]$rawHeaders){
        <#
        .SYNOPSIS
        Parse for headers
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
