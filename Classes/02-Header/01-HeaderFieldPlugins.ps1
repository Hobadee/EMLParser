class HeaderFieldPlugins {
    <#
    .SYNOPSIS
    Singleton class to handle registration of Header Field plugins
    #>

    static [HeaderFieldPlugins] $Instance = $null  # Explicitly initialize to $null
    static [System.Collections.Generic.List[PluginHeader]] $Plugins = $null
    [System.Collections.Generic.Dictionary[string, [Type]]] $PluginRegistry

    static [HeaderFieldPlugins] GetInstance() {
        if ($null -eq [HeaderFieldPlugins]::Instance) {
            [HeaderFieldPlugins]::Instance = [HeaderFieldPlugins]::new()
        }
        return [HeaderFieldPlugins]::Instance
    }

    HeaderFieldPlugins() {
        #$this.Plugins = [System.Collections.Generic.List[PluginHeader]]::new()
        $this.PluginRegistry = [System.Collections.Generic.Dictionary[string, [Type]]]::new()
    }

    <#
    static [void]register([PluginHeader]$plugin){
        $inst = [HeaderFieldPlugins]::GetInstance()
        $inst.Plugins.Add($plugin)
        #[HeaderFieldPlugins]::Plugins.Add($plugin)
    }
    #>

     [void]RegisterPlugin([Type] $pluginType) {
        # Ensure the type implements PluginHeader
        $plugin = [Activator]::CreateInstance($pluginType)
        if (-not ($plugin -is [PluginHeader])) {
                throw [ArgumentException]::New("The provided type does not implement PluginHeader.")
        }

        # Add each field name to the registry, mapping it to the plugin type
        foreach ($field in $pluginType::fieldNames()) {
            $this.PluginRegistry[$field] = $pluginType
        }
    }

    [PluginHeader] GetPluginForField([string] $headerField) {
        if ($this.PluginRegistry.ContainsKey($headerField)) {
            # Instantiate and return the appropriate plugintes
            $pluginType = $this.PluginRegistry[$headerField]
            Write-Debug "Found plugin for field '$headerField': $pluginType"
            return [Activator]::CreateInstance($pluginType)
        }
        return $null  # No matching plugin found
    }

}
