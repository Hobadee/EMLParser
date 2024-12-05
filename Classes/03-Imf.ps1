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

            .NOTES
            We should probably trim all extra whitespace to a single space character as well
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
