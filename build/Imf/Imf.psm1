#Region './Classes/01-HeaderField.ps1' 0
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
    hidden [String]$_name
    hidden [String]$_body


    #
    # Class Constructors
    #
    HeaderField(){
    }


    #
    # Getters/Setters
    #
    [HeaderField]setName([String]$name){
        $this._name = $name
        return $this
    }
    [String]getName(){
        return $this._name
    }


    [HeaderField]setBody([String]$body){
        $this._body = $body
        return $this
    }
    [String]getBody(){
        return $this._body
    }


    #
    # Magic Methods
    #
    [String]toString(){
        $rtn = $this._name + ": " + $this._body
        return $rtn
    }

}
#EndRegion './Classes/01-HeaderField.ps1' 68
#Region './Classes/02-Headers.ps1' 0
class Headers : System.Collections.Generic.List[PSObject]{
    <#
    .SYNOPSIS
    Class to hold all Header Fields

    .DESCRIPTION
    Used by the Imf class to hold all header fields
    #>


    [HeaderField]getHeaderByName([string]$name){
        <#
            .SYNOPSIS
            Returns the *FIRST* header matching $name
        #>
        foreach($header in $this){
            if($header.getName() -eq $name){
                return $header
            }
        }
        return $null
    }


    [PSObject]getHeadersByName([string]$name){
        <#
            .SYNOPSIS
            Returns an array of all headers matching a name
        #>

        $rtnArray = New-Object System.Collections.Generic.List[PSObject]

        foreach($header in $this){
            if($header.getName() -eq $name){
                $rtnArray.Add($header)
            }
        }
        
        return $rtnArray
    }



}
#EndRegion './Classes/02-Headers.ps1' 45
#Region './Classes/03-Imf.ps1' 0
class Imf{
    <#
    .SYNOPSIS
    Class to handle parsing of Internet Message Format messages (IMF)
    This class should handle RFC 5322 formatted messages.  These are
    typically stored on a computer as an EML format file.
    #>


    # Class variables
    # I can't remember - does declaring them here make them global to all instances, or is that Python?!
    hidden [String]$_RawImf
    hidden [Headers]$_Headers


    #
    # Class Constructors
    #
    Imf(){
        $this._Headers = [Headers]::new()
    }


    #
    # Getters/Setters
    #
    [Imf]setRawData([String]$data){
        <#
        .SYNOPSIS
        Set raw IMF data

        .NOTES
        Content MUST be passed in RAW mode!
        ie: `Get-Content -Raw test.eml`
        Failure to pass raw data will cause parsing errors down the line!
        #>
        $this._RawImf = $data
        return $this
    }
    [String]getRawData(){
        return $this._RawImf
    }


    #
    # Class Functions
    #
    [Imf]unfold(){
        <#
            .SYNOPSIS
            Function to unfold header fields

            .DESCRIPTION
            RFC 5322 - 2.2.3 - https://datatracker.ietf.org/doc/html/rfc5322#section-2.2.3
        #>

        # Unfold by "s/\r\n\s+/ /"
        # https://stackoverflow.com/questions/53867147/grep-and-sed-equivalent-in-powershell
        # ^ ??

        # Folded data is CRLF+whitespace
        $search = '\r\n\s+'
        # We need to replace with a single space so we don't concatenate the data
        $replace = ' '

        $this._RawImf = $this._RawImf -replace $search, $replace

        return $this
    }


    [Imf]fold([String]$imf){
        <#
            .SYNOPSIS
            Function to fold header fields

            .DESCRIPTION
            RFC 5322 - 2.2.3 - https://datatracker.ietf.org/doc/html/rfc5322#section-2.2.3
        #>

        # This isn't terribly important for our purposes right now.  Implement later, if ever.
        throw System.NotImplementedException::New('"Fold" Method not implemented')

        return $this

    }


    [Imf]parseHeaders(){
        <#
        .SYNOPSIS
        Parse $self._RawImf for headers
        #>

        Write-Debug("Parsing headers")

        #$search = '^([^:]+):(.*)$'
        $search = '^(?<Name>[^:]+):(?<Body>.*)$'
        #$search = '(?<Name>[^:]+):(?<Body>.*)'
        $regex = [regex]::new($search, [System.Text.RegularExpressions.RegexOptions]::Multiline)

        $matches = $regex.Matches($this._RawImf)
        Write-Debug("Headers found: $($matches.Count)")

        foreach ($match in $matches){
            $name = $match.Groups["Name"].Value
            $body = $match.Groups["Body"].Value
            $hf = [HeaderField]::new()
            $hf.setName($name).setBody($body)
            $this._Headers.Add($hf)
        }

        return $this
    }

}
#EndRegion './Classes/03-Imf.ps1' 117
#Region './Public/test.ps1' 0
function test{
        [CmdletBinding(SupportsShouldProcess=$true)]
        param (
        )
        
        $data = Get-Content -Raw ./testEmail.eml

        $imf = [Imf]::new()
        $imf.setRawData($data)

        $imf.unfold()
        $imf.parseHeaders()

        return $imf
}
#EndRegion './Public/test.ps1' 16
