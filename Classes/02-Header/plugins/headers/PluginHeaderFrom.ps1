class PluginHeaderFrom : IPluginHeader {


    
    [void]ParseBody() {
        <#
        .SYNOPSIS
        Parse the header field as needed for the plugin
        #>

        $search = '(?:(?<Name>.+)\s+)?<(?<Username>.+)@(?<Domain>.+)>'
        $regex = [regex]::new($search)

        $match = $regex.Matches($this.Body)

        $this.Name = $match[0].Groups["Name"].Value
        $Username = $match[0].Groups["Username"].Value
        $Domain = $match[0].Groups["Domain"].Value
        $this.Email = [Email]::new($Username, $Domain)

    }


    static [Array]fieldNames(){
        <#
        .SYNOPSIS
        Return a string of header fields this plugin works for.
        #>
        $names = @(
            "From"
        )
        return $names
    }

}

[HeaderFieldPlugins]::GetInstance().RegisterPlugin([PluginHeaderFrom])
