<#
.SYNOPSIS
Returns a list of all registered header plugins and their handled header types.

.DESCRIPTION
Queries the HeaderFieldPlugins singleton to retrieve information about all registered
plugins, including which header field names each plugin handles.

.OUTPUTS
System.Object[] - Array of objects with plugin information (Name, HandledHeaders)

.EXAMPLE
Get-ImfPlugins

Returns all registered header field plugins and their handled header types.
#>
function Get-ImfPlugin {
    [CmdletBinding()]
    param()

    $plugins = [HeaderFieldPlugins]::GetInstance()

    foreach ($key in $plugins.PluginRegistry.Keys) {
        # Write-Output "Registered Header Field: $key -> $($plugins.PluginRegistry[$key])"
        
        [PSCustomObject]@{
            PluginName      = $plugins.PluginRegistry[$key]
            HandledHeader  = $key
        }
    }
    
    # foreach ($plugin in $plugins) {
    #     $pluginType = $plugin.GetType()
    #     [PSCustomObject]@{
    #         PluginName      = $plugin.GetType().Name
    #         HandledHeaders  = $pluginType::fieldNames()
    #     }
    # }
}
