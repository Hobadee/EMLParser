class PluginHeaderReceived : IPluginHeader {
    [void]ParseBody() {
        Write-Host "Parsing 'Received' header field..."
    }

    static [string[]]fieldNames() {
        return @("Received", "X-Received")
    }
}

$pluginManager = [HeaderFieldPlugins]::GetInstance()
$pluginManager.RegisterPlugin([PluginHeaderReceived])


<#
$plugin = $pluginManager.GetPluginForField("Received")
if ($plugin -ne $null) {
    $plugin.ParseBody()
} else {
    Write-Host "No plugin found for the header field."
}
#>
