class Headers : System.Collections.Generic.List[PSObject]{
    <#
    .SYNOPSIS
    Class to hold all Header Fields

    .DESCRIPTION
    Used by the Imf class to hold all header fields
    #>


    [HeaderField]getHeaderByName([string]$name){
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
            Returns an array of all headers matching a name
        #>

        $rtnArray = New-Object System.Collections.Generic.List[PSObject]

        foreach($header in $this){
            if($header.getName() -eq $name){
                $rtnArray.Add($header)
            }
        }
        
        return $rtnArray
    }



}
