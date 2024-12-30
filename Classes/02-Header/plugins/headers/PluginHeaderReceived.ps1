class PluginHeaderReceived : PluginHeader {

    [string]$Timestamp
    [string]$Server

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
