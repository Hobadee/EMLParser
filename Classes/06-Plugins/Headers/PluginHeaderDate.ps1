class PluginHeaderDate : PluginHeader {
    <#
    .SYNOPSIS
    Plugin to parse RFC 5322 Date header fields

    .DESCRIPTION
    Handles the "Date" header field which contains an RFC 5322 formatted timestamp.
    Parses the date string into a Timestamp object for easy access to date components
    and timezone information.
    #>

    [Timestamp]$Timestamp


    PluginHeaderDate() : base(){
        <#
        .SYNOPSIS
        Default constructor for PluginHeaderDate
        #>
        # Default constructor - let base initialize
    }

    PluginHeaderDate([string]$name, [string]$body) : base($name, $body){
        <#
        .SYNOPSIS
        Constructor that takes a header name and body, then parses the date

        .PARAMETER name
        The header field name (should be "Date")

        .PARAMETER body
        The RFC 5322 formatted date string
        #>
        # Forward to base constructor so ParseBody() is invoked
    }


    [void]ParseBody() {
        <#
        .SYNOPSIS
        Parse the header field body as an RFC 5322 date

        .DESCRIPTION
        Parses the body into a Timestamp object which handles:
        - Optional day-of-week prefix (Sat, etc.)
        - Proper timezone offset handling
        - Storage of parsed components in DateTimeOffset

        .NOTES
        If parsing fails, the Timestamp will be created with default values.
        #>
        
        try {
            # Create a Timestamp from the date string
            $this.Timestamp = [Timestamp]::new($this.Body)
        }
        catch {
            # If parsing fails, create an empty Timestamp
            $this.Timestamp = [Timestamp]::new()
        }
    }

    static [string[]]fieldNames() {
        <#
        .SYNOPSIS
        Return an array of field names this plugin handles

        .DESCRIPTION
        This plugin handles the "Date" header field as defined in RFC 5322

        .OUTPUTS
        Array of header field names (strings)
        #>
        return @(
            "Date"
            "X-Date"
        )
    }
}

[HeaderFieldPlugins]::GetInstance().RegisterPlugin([PluginHeaderDate])
