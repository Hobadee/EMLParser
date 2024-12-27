class HeaderFieldPlugins {
    <#
    .SYNOPSIS
    Singleton class to handle registration of Header Field plugins
    #>

    static [HeaderFieldPlugins] $Instance = $null  # Explicitly initialize to $null
    static [System.Collections.Generic.List[IPluginHeader]] $Plugins = $null
    [System.Collections.Generic.Dictionary[string, [Type]]] $PluginRegistry

    static [HeaderFieldPlugins] GetInstance() {
        if ($null -eq [HeaderFieldPlugins]::Instance) {
            [HeaderFieldPlugins]::Instance = [HeaderFieldPlugins]::new()
        }
        return [HeaderFieldPlugins]::Instance
    }

    HeaderFieldPlugins() {
        #$this.Plugins = [System.Collections.Generic.List[IPluginHeader]]::new()
        $this.PluginRegistry = [System.Collections.Generic.Dictionary[string, [Type]]]::new()
    }

    <#
    static [void]register([IPluginHeader]$plugin){
        $inst = [HeaderFieldPlugins]::GetInstance()
        $inst.Plugins.Add($plugin)
        #[HeaderFieldPlugins]::Plugins.Add($plugin)
    }
    #>

     [void]RegisterPlugin([Type] $pluginType) {
        # Ensure the type implements IPluginHeader
        if (-not ($pluginType -is [IPluginHeader])) {
            throw [ArgumentException]::New("The provided type does not implement IPluginHeader.")
        }

        # Add each field name to the registry, mapping it to the plugin type
        foreach ($field in $pluginType::fieldNames()) {
            $this.PluginRegistry[$field] = $pluginType
        }
    }

    [IPluginHeader] GetPluginForField([string] $headerField) {
        if ($this.PluginRegistry.ContainsKey($headerField)) {
            # Instantiate and return the appropriate plugin
            $pluginType = $this.PluginRegistry[$headerField]
            return [Activator]::CreateInstance($pluginType)
        }
        return $null  # No matching plugin found
    }

}
