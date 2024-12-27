class IPluginHeader{
    <#
    .SYNOPSIS
    Interface for header-field plugins to implement
    #>


    [string]$Name = $null
    [string]$Body = $null


    [void]ParseBody() {
        <#
        .SYNOPSIS
        Parse the header field as needed for the plugin
        #>
        throw [NotImplementedException]::New("Interface must be implemented!")
    }


    static [Array]fieldNames(){
        <#
        .SYNOPSIS
        Return a string of header fields this plugin works for.

        .EXAMPLE
        $names = @(
            "Received"
            "X-Received"
        )
        return $names
        #>
        throw [NotImplementedException]::New("Interface must be implemented!")
    }


}
