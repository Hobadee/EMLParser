class PluginHeaderReceived : PluginHeader {

    [string]$Timestamp
    [string]$Server


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
        Extract timestamp and server from a "received" header field
        #>

        # TODO: Implement this method
        $this.Timestamp = "Parsed Timestamp"
        $this.Server = "Parsed Server"
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
