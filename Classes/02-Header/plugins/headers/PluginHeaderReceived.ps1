class PluginHeaderReceived : IPluginHeader {
    [void]ParseBody() {
        Write-Host "Parsing 'Received' header field..."
    }

    static [string[]]fieldNames() {
        return @("Received", "X-Received")
    }
}

[HeaderFieldPlugins]::GetInstance().RegisterPlugin([PluginHeaderReceived])
