class HeaderField{
    <#
    .SYNOPSIS
    Class to hold a header field

    .DESCRIPTION
    Used by the Header class to hold a single header field

    .NOTES
    Plugins implement this via the PluginHeader class
    #>


    # Class variables
    [string]$Name
    [string]$Body


    #
    # Class Constructors
    #
    HeaderField(){
        <#
        .SYNOPSIS
        Class constructor for the HeaderField class
        #>
        $this.Name = $null
        $this.Body = $null
    }
    HeaderField([string]$name, [string]$body){
        <#
        .SYNOPSIS
        Class constructor for the HeaderField class

        .PARAMETER name
        The name of the header field

        .PARAMETER body
        The body of the header field
        #>
        $this.Name = $name
        $this.Body = $body
        
        $this.ParseBody()
    }


    #
    # Getters/Setters
    #
    [HeaderField]setName([string]$name){
        <#
        .SYNOPSIS
        Set the name of the header field

        .PARAMETER name
        The name of the header field

        .OUTPUTS
        The current object
        #>
        $this.Name = $name
        return $this
    }
    [string]getName(){
        <#
        .SYNOPSIS
        Get the name of the header field

        .RETURN
        The name of the header field
        #>
        return $this.Name
    }


    [HeaderField]setBody([string]$body){
        <#
        .SYNOPSIS
        Set the body of the header field
        #>
        $this.Body = $body.Trim()
        return $this
    }
    [string]getBody(){
        <#
        .SYNOPSIS
        Return the header field body, striping excess whitespace

        .DESCRIPTION
        Since you *probably* don't care about whitespace, we will strip
        excessive whitespace before returning the header data
        
        .OUTPUTS
        The body of the header field with excess whitespace removed
        #>

        # Replace multiple whitespace with single space
        $str = $this.Body
        $search = '\s{2,}'
        $regex = [regex]::new($search, [System.Text.RegularExpressions.RegexOptions]::Multiline)
        $str = $regex.Replace($str, ' ')

        return $str
    }
    [string]getBodyRaw(){
        <#
        .SYNOPSIS
        Return the raw data of a header field body

        .DESCRIPTION
        This is usefull if you need to see the extra whitespace a header field
        may contain for some reason. You probably don't, but I'm not seeing
        anything obvious in RFC5322 precluding the possiblility

        .OUTPUTS
        The raw body of the header field
        #>

        return $this.Body
    }


    #
    # "Abstract" methods
    #
    [void]ParseBody() {
        # Default behavior for generic headers
        <#
        .SYNOPSIS
        Parse the header as needed

        .DESCRIPTION
        Default implementation is to throw an exception.  This should be overridden.
        #>
        throw [NotImplementedException]::New("Interface must be implemented!")
    }


    #
    # Magic Methods
    #
    [string]ToString(){
        <#
        .SYNOPSIS
        Returns a string representation of the header field in the format "Name: Body"
        #>
        $rtn = $this.getName() + ": " + $this.getBody()
        return $rtn
    }

}
