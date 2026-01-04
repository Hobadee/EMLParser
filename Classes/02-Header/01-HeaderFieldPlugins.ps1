class HeaderFieldPlugins {
    <#
    .SYNOPSIS
    Singleton class to handle registration of Header Field plugins

    .DESCRIPTION
    This singleton class provides methods to register and retrieve header field plugins.
    It maintains a dictionary mapping header field names to their corresponding plugin types.

    .NOTES
    This class maintains a registry of header field plugins for parsing email headers.
    Each plugin must implement the PluginHeader class.
    #>


    # $Instance: The singleton instance of HeaderFieldPlugins
    # $Plugins: A list of registered plugins
    # $PluginRegistry: A dictionary mapping header field names to their plugin types
    static [HeaderFieldPlugins] $Instance = $null  # Explicitly initialize to $null
    static [System.Collections.Generic.List[PluginHeader]] $Plugins = $null
    [System.Collections.Generic.Dictionary[string, [Type]]] $PluginRegistry


    static [HeaderFieldPlugins] GetInstance() {
        <#
        .SYNOPSIS
        Get the singleton instance of HeaderFieldPlugins.

        .NOTES
        This method ensures that only one instance of HeaderFieldPlugins exists.
        #>
        if ($null -eq [HeaderFieldPlugins]::Instance) {
            [HeaderFieldPlugins]::Instance = [HeaderFieldPlugins]::new()
        }
        return [HeaderFieldPlugins]::Instance
    }


    HeaderFieldPlugins() {
        <#
        .SYNOPSIS
        Initialize a new instance of the HeaderFieldPlugins class.

        .DESCRIPTION
        This constructor initializes the plugin registry dictionary.

        .NOTES
        No way of enforcing `private` constructor in PowerShell, but this is intended to be used only via GetInstance().
        #>

        #$this.Plugins = [System.Collections.Generic.List[PluginHeader]]::new()
        $this.PluginRegistry = [System.Collections.Generic.Dictionary[string, [Type]]]::new()
    }


    [void]RegisterPlugin([Type] $pluginType) {
        <#
        .SYNOPSIS
        Register a plugin type for header field parsing

        .PARAMETER pluginType
        The type of the plugin to register. Must implement PluginHeader.

        .NOTES
        This method registers a plugin type for handling specific header fields.
        #>
        
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
        <#
        .SYNOPSIS
        Get the appropriate plugin for a given header field.

        .PARAMETER headerField
        The name of the header field to find a plugin for.

        .NOTES
        This method returns an instance of the appropriate plugin type for the given header field.
        #>

        Write-Debug("Finding plugin for header: $headerField")
        if ($this.PluginRegistry.ContainsKey($headerField)) {
            # Instantiate and return the appropriate plugintes
            $pluginType = $this.PluginRegistry[$headerField]
            Write-Debug "HeaderFieldPluigins::GetPluginForField - Found plugin for field '$headerField': $pluginType"
            return [Activator]::CreateInstance($pluginType)
        }
        return $null  # No matching plugin found
    }

}
