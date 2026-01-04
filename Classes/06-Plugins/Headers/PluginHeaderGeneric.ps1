class PluginHeaderGeneric : PluginHeader {


    PluginHeaderGeneric() : base(){
        # Default constructor - let base initialize
    }
    PluginHeaderGeneric([string]$name, [string]$body) : base($name, $body){
        # Forward to base constructor so ParseBody() is invoked
    }
    

    [void]ParseBody(){
        <#
        .SYNOPSIS
        # Default constructor - let base initialize
        #>
    }


    static [Array]fieldNames(){
        <#
        .SYNOPSIS
        Return a string of header fields this plugin works for.
        #>
        $names = @(
            # Wildcards aren't currently supported, but in the future they might be
            # For now this plugin is manually forced, so it doesn't matter that it doesn't match anything
            "*"
        )
        return $names
    }

}

[HeaderFieldPlugins]::GetInstance().RegisterPlugin([PluginHeaderGeneric])
