class PluginHeaderEmail : PluginHeader {

    [string]$Name
    [Email]$Email


    [void]ParseBody() {
        <#
        .SYNOPSIS
        Parse the header field as needed for the plugin

        .DESCRIPTION
        This plugin will parse the 'From' header field and extract the name and email address.
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
            "X-Original-From"
            "Reply-To"
        )
        return $names
    }

}

[HeaderFieldPlugins]::GetInstance().RegisterPlugin([PluginHeaderEmail])
