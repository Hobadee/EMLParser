class PluginHeaderList : PluginHeader {
    <#
    .NOTES
    List-Post: <https://groups.google.com/a/pliancy.com/group/notifications-slwm/post>,
        <mailto:notifications-slwm@pliancy.com>
    List-Help: <https://support.google.com/a/pliancy.com/bin/topic.py?topic=25838>,
        <mailto:notifications-slwm+help@pliancy.com>
    List-Archive: <https://groups.google.com/a/pliancy.com/group/notifications-slwm/>
    List-Unsubscribe: <mailto:googlegroups-manage+1086526740430+unsubscribe@googlegroups.com>,
        <https://groups.google.com/a/pliancy.com/group/notifications-slwm/subscribe>

    TODO: This doesn't work.  :-( 
    #>

    [string]$ListType
    [string]$ListUrl
    [System.Net.Mail.MailAddress]$ListEmail


    PluginHeaderList() : base(){
        # Default constructor - let base initialize
    }
    PluginHeaderList([string]$name, [string]$body) : base($name, $body){
        # Forward to base constructor so ParseBody() is invoked
    }


    [void]ParseBody() {
        <#
        .SYNOPSIS
        Parse the header field as needed for the plugin

        .DESCRIPTION
        This plugin will parse List-* headers

        .NOTES
        Not sure if this is a consistent order I need to parse these in, but this is the order Google uses
        TODO: Check if this is in the RFC and update as needed
        #>
        $search = 'List-(?<ListType>[^:]+):\s+<(?<Part1>[^>]+)>(?:,\s+<(?<Part2>[^>]+)>)?'
        $regex = [regex]::new($search)

        $match = $regex.Matches($this.Body)

        try{
            $this.ListType = $match[0].Groups["ListType"].Value

            switch -Regex ($match[0].Groups["Part1"].Value) {
                '^https?\:.*' {
                    # $_ is HTTP
                    $this.ListUrl = $_
                }
                '^mailto\:.*' {
                    # $_ is mailto
                    # Substring(7) to remove `mailto:`
                    $this.ListEmail = [System.Net.Mail.MailAddress]::new($_.Substring(7))
                }
                Default {}
            }
            
            # I don't know if these won't overwrite each other, but the Google example works fine this way
            switch -Regex ($match[0].Groups["Part2"].Value) {
                '^https?\:.*' {
                    # $_ is HTTP/S
                    $this.ListUrl = $_
                }
                '^mailto\:.*' {
                    # $_ is mailto
                    # Substring(7) to remove `mailto:`
                    $this.ListEmail = [System.Net.Mail.MailAddress]::new($_.Substring(7))
                }
                Default {}
            }
        }
        catch{
            "Write-Error('Error parsing List-* header: $_')"
        }

    }


    static [Array]fieldNames(){
        <#
        .SYNOPSIS
        Return a string of header fields this plugin works for.
        #>
        $names = @(
            "List-Post"
            "List-Help"
            "List-Archive"
            "List-Unsubscribe"
            "List-Unsubscribe-Post"
        )
        return $names
    }

}

[HeaderFieldPlugins]::GetInstance().RegisterPlugin([PluginHeaderList])
