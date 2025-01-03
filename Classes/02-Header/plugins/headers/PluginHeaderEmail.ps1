class PluginHeaderEmail : PluginHeader {

    [Email]$Email


    [void]ParseBody() {
        <#
        .SYNOPSIS
        Parse the header field as needed for the plugin

        .DESCRIPTION
        This plugin will parse the 'From' header field and extract the name and email address.
        #>
        $search = '^(?<Email>.+@.+)$'
        $regex = [regex]::new($search)

        $match = $regex.Matches($this.Body)

        $address = $match[0].Groups["Email"].Value

        $this.Email = [Email]::new($address)
    }


    static [Array]fieldNames(){
        <#
        .SYNOPSIS
        Return a string of header fields this plugin works for.
        #>
        $names = @(
            "Delivered-To"
        )
        return $names
    }

}

[HeaderFieldPlugins]::GetInstance().RegisterPlugin([PluginHeaderEmail])
