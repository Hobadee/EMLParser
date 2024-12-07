class HeaderField{
    <#
    .SYNOPSIS
    Class to hold a header field

    .DESCRIPTION
    Used by the Header class to hold a single header field

    .NOTES
    We need a way of having multiple different Header Field types
    to handle things like routing headers, to/cc/bcc, etc...

    Maybe needs to be a strategy pattern?  This locks us into an interface though
    which we may not want - we may need to have flexible methods per type
    Is there a pattern that supports this?

    Possible patterns to look into:
    - Strategy
    - Template Method
    - Decorator (Probably not - used for multiple concurrent states of a single item)
    - State (Probably not - we aren't changing state of a single object)

    #>


    # Class variables
    [string]$Name
    [string]$Body


    #
    # Class Constructors
    #
    HeaderField([string]$name, [string]$body){
        $this.Name = $name
        $this.Body = $body
    }


    #
    # Getters/Setters
    #
    [HeaderField]setName([string]$name){
        #Write-Debug("HeaderField.setName()")
        $this.Name = $name
        return $this
    }
    [string]getName(){
        #Write-Debug("HeaderField.getName()")
        return $this.Name
    }


    [HeaderField]setBody([string]$body){

        #Write-Debug("HeaderField.setBody()")

        # Trim begining whitespace
        $search = '^\s+'
        $regex = [regex]::new($search, [System.Text.RegularExpressions.RegexOptions]::Multiline)
        $trimmed = $regex.Replace($body, '')

        $this.Body = $trimmed
        return $this
    }
    [string]getBody(){
        <#
        .SYNOPSIS
        Return the header field body, striping excess whitespace

        .DESCRIPTION
        Since you *probably* don't care about whitespace, we will strip
        excessive whitespace before returning the header data
        #>

        #Write-Debug("HeaderField.getBody()")

        $str = $this.Body
        $search = '\s{2,}'

        $regex = [regex]::new($search, [System.Text.RegularExpressions.RegexOptions]::Multiline)

        $str = $regex.Replace($str, '')

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
        #>

        #Write-Debug("HeaderField.getBodyRaw()")

        return $this.Body
    }


    #
    # "Abstract" methods
    #
    [void]ParseBody() {
        # Default behavior for generic headers
    }

    static [Array]fieldNames(){
        <#
        .SYNOPSIS
        Return an array of field names a given plugin can handle

        .NOTES
        Abstract method - implement in child!
        #>
        throw System.NotImplementedException::New('Abstract method not implemented in child class')
    }


    #
    # Magic Methods
    #
    [string]ToString(){
        #Write-Debug("HeaderField.ToString()")
        $rtn = $this.getName() + ": " + $this.getBody()
        return $rtn
    }

}
