class Imf{
    <#
    .SYNOPSIS
    Class to handle parsing of Internet Message Format messages (IMF)
    This class should handle RFC 5322 formatted messages.  These are
    typically stored on a computer as an EML format file.
    #>


    # Class variables
    # I can't remember - does declaring them here make them global to all instances, or is that Python?!
    # I checked; No, they are instance variables - NOT static/global
    [string]$RawImf
    [Headers]$Headers
    [array]$attachments


    #
    # Class Constructors
    #
    Imf(){
        $this.Headers = [Headers]::new()
    }


    ###################
    # Getters/Setters #
    ###################

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

        $varHeaders = $this.getHeaderData($true)
        $this.Headers.parseHeaders($varHeaders)

        return $this
    }


    [string]getRawData(){
        <#
        .SYNOPSIS
        Get raw IMF data

        .NOTES
        Returns the raw IMF data as a string.
        #>
        return $this.RawImf
    }


    [Imf]setHeaders([Headers]$headers){
        <#
        .SYNOPSIS
        Set the header object for this IMF object

        .PARAMETER headers
        The Headers object to set

        .OUTPUTS
        The Imf object with the updated Headers property

        .NOTES
        This method is used to set the headers for this IMF object.

        If a header object is already set, an exception will be thrown.
        #>
        if($null -ne $this.Headers){
           throw System.System.AccessViolationException::New('Headers already set - cannot overwrite!')
        }
        $this.Headers = $headers
        return $this
    }


    [Headers]getHeaders(){
        <#
        .SYNOPSIS
        Get the header object for this IMF object

        .NOTES
        Returns the Headers object for this IMF object.
        #>
        return $this.Headers
    }


    ###################
    # Class Functions #
    ###################

    [string]getHeaderData($unfolded = $true){
        <#
            .SYNOPSIS
            Extract just the header portion of the message

            .DESCRIPTION
            RFC 5322 specifies that headers and body are separated by a blank line (CRLF CRLF).
            This function returns everything before that blank line.

            .PARAMETER unfolded
            If $true, will return unfolded header data (default).  If $false, will return raw
            (probably folded) header data.

            .NOTES
            Returns the raw header data, including the blank line separator
        #>

        # Match everything up to and including the first blank line (CRLF CRLF)

        $search = '(?s)^(.*?)\r\n\r\n'
        $regex = [regex]::new($search, [System.Text.RegularExpressions.RegexOptions]::Multiline)
        $match = $regex.Match($this.RawImf)


        if ($match.Success) {
            Write-Debug("Imf.GetHeaderData() - Found Header Data: $($match.Groups[1].Value.Length) characters")
            # `$varHeaders` to prevent namespace collision with class variable
            $varHeaders = $match.Groups[1].Value
        }
        else {
            Write-Debug("No header data found in IMF message.")
            throw [System.Exception]::New("No header data found in IMF message.")
        }

        if ($unfolded) {
            
            # Per RFC, folded data is CRLF+whitespace
            # Unfold by "s/\r\n\s+/ /"
            $search = '\r\n\s+'
            $regex = [regex]::new($search)
            $matches1 = $regex.Matches($varHeaders)
            Write-Debug("Imf.GetHeaderData() - Unfolding: Found $($matches1.Count) folding patterns")
            # We need to replace with a single space so we don't concatenate the data
            $varHeaders = $regex.Replace($varHeaders, ' ')

            # Trim extra whitespace
            $search = ' {2,}'
            $regex = [regex]::new($search)
            $matches2 = $regex.Matches($varHeaders)
            Write-Debug("Imf.GetHeaderData() - Trimming: Found $($matches2.Count) extra whitespace patterns")
            $varHeaders = $regex.Replace($varHeaders, ' ')
        }

        return $varHeaders
    }


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

        $path = $this.getHeaders().getHeadersByName("(X-)?Received")
        
        return $path

    }

    [string]getBodyData(){
        <#
            .SYNOPSIS
            Extract just the body portion of the message

            .DESCRIPTION
            RFC 5322 specifies that headers and body are separated by a blank line (CRLF CRLF).
            This function returns everything after that blank line.

            .NOTES
            Returns the raw message body; preserves original line endings and formatting
        #>

        # Match everything after the first blank line (CRLF CRLF)
        $search = '(?s)^\r\n\r\n(.*)$'
        $regex = [regex]::new($search)
        $match = $regex.Match($this.RawImf)

        if ($match.Success) {
            Write-Debug("Found body data: $($match.Groups[1].Value.Length) characters")
            return $match.Groups[1].Value
        }

        Write-Debug("No blank line separator found; body data is empty")
        return ""
    }

    # TODO: Not compiling currently - fix later
    # [array]getAttachmentData(){
    #     <#
    #         .SYNOPSIS
    #         Extract attachment data from the message body

    #         .DESCRIPTION
    #         Parses MIME multipart messages to identify and extract attachments.
    #         Attachments are identified by Content-Disposition: attachment headers.

    #         .NOTES
    #         Currently returns an array of attachment objects for later refactoring.
    #         Stores results in $this.attachments
    #     #>

    #     Write-Debug("Imf.getAttachmentData()")

    #     $this.attachments = @()
    #     $body = $this.getBodyData()

    #     # Look for Content-Disposition: attachment headers in the body
    #     $search = 'Content-Disposition:\s*attachment[^`n]*filename[^=]*=\s*["\']?([^"\'`r`n]+)["\']?'
    #     $regex = [regex]::new($search, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    #     $matches = @($regex.Matches($body))

    #     Write-Debug("Found $($matches.Count) attachments")

    #     foreach ($match in $matches) {
    #         $filename = $match.Groups[1].Value
    #         Write-Debug("Found attachment: $filename")
            
    #         $attachmentObj = [PSCustomObject]@{
    #             Filename = $filename
    #             # Additional properties can be added here during refactoring
    #         }

    #         $this.attachments += $attachmentObj
    #     }

    #     return $this.attachments
    # }

}
