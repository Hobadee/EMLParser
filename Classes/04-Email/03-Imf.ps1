class Imf{
    <#
    .SYNOPSIS
    Class to handle parsing of Internet Message Format messages (IMF)
    This class should handle RFC 5322 formatted messages.  These are
    typically stored on a computer as an EML format file.
    #>


    # Class variables
    # I can't remember - does declaring them here make them global to all instances, or is that Python?!
    [string]$RawImf
    [Headers]$Headers


    #
    # Class Constructors
    #
    Imf(){
        $this.Headers = [Headers]::new()
    }


    #
    # Getters/Setters
    #
    [Imf]setRawData([string]$data){
        <#
        .SYNOPSIS
        Set raw IMF data

        .NOTES
        Content MUST be passed in RAW mode!
        ie: `Get-Content -Raw test.eml`
        Failure to pass raw data will cause parsing errors down the line!
        #>

        $this.RawImf = $data
        $this.unfold()

        $this.Headers.parseHeaders($this.RawImf)

        return $this
    }
    [string]getRawData(){

        Write-Debug("Imf.getRawData()")

        return $this.RawImf
    }


    [Imf]setHeaders([Headers]$headers){
        if($null -ne $this.Headers){
           throw System.System.AccessViolationException::New('Headers already set - cannot overwrite!')
        }
        $this.Headers = $headers
        return $this
    }
    [Headers]getHeaders(){

        #Write-Debug("Imf.getHeaders()")

        return $this.Headers
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

        Write-Debug("Imf.unfold()")

        # Unfold by "s/\r\n\s+/ /"
        # https://stackoverflow.com/questions/53867147/grep-and-sed-equivalent-in-powershell
        # ^ ??

        # Folded data is CRLF+whitespace
        $search = '\r\n\s+'
        # We need to replace with a single space so we don't concatenate the data
        $replace = ' '

        $this.RawImf = $this.RawImf -replace $search, $replace

        return $this
    }


    [Imf]fold([string]$imf){
        <#
            .SYNOPSIS
            Function to fold header fields

            .DESCRIPTION
            RFC 5322 - 2.2.3 - https://datatracker.ietf.org/doc/html/rfc5322#section-2.2.3

            Does fancy magic to ensure nothing over 80 characters per line.  Except when there should be.
        #>

        Write-Debug("Imf.fold()")

        # This isn't terribly important for our purposes right now.  Implement later, if ever.
        throw System.NotImplementedException::New('"Fold" Method not implemented')

        return $this

    }


    # [Imf]parseHeaders(){
    #     <#
    #     .SYNOPSIS
    #     Parse $self._RawImf for headers
    #     #>

    #     Write-Debug("Imf.parseHeaders()")

    #     $search = '^(?<Name>[^:]+):(?<Body>.*)$'
    #     $regex = [regex]::new($search, [System.Text.RegularExpressions.RegexOptions]::Multiline)

    #     $matches = $regex.Matches($this.RawImf)
    #     Write-Debug("Headers found: $($matches.Count)")

    #     foreach ($match in $matches){
    #         $name = $match.Groups["Name"].Value
    #         $body = $match.Groups["Body"].Value
    #         $hf = [HeaderField]::new()
    #         $hf.setName($name).setBody($body)
    #         $this.getHeaders().Add($hf)
    #     }

    #     return $this
    # }


    [PSObject]getPath(){
        <#
        .SYNOPSIS
        Gets the path the message took.  Uses `Received` headers

        .NOTES
        TODO:   Order path properly
                    We can't sort by timestamps since we don't have microseconds
                Do we need to include X-Recieved?
        #>

        Write-Debug("Imf.getPath()")

        $path = $this.getHeaders().getHeadersByName("Received")
        
        return $path

    }

}
