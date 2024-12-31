class PluginHeader: HeaderField{
    <#
    .SYNOPSIS
    Parent class for header-field plugins to implement

    .DESCRIPTION
    Used by the Header class to hold a single header field

    .NOTES
    Plugins inherit from HeaderField, so they should get the following properties:
    - [string]$Name
    - [string]$Body

    And the following methods:
    - public [void]__construct([string]$name, [string]$body)
    - public [void]setName([string]$name)
    - public [string]getName()
    - public [void]setBody([string]$body)
    - public [string]getBody()
    - public [string]getBodyRaw()

    #>

    
    #
    # Plugin functions
    #
    [void]ParseBody() {
        <#
        .SYNOPSIS
        Parse the header field as needed for the plugin

        .DESCRIPTION
        Default implementation is to throw an exception.  This should be overridden.
        #>
        throw [NotImplementedException]::New("Interface must be implemented!")
    }


    static [Array]fieldNames(){
        <#
        .SYNOPSIS
        Return an array of field names a given plugin can handle

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
