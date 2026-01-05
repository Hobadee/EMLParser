class Timestamp {
    <#
    .SYNOPSIS
    Class to parse and represent RFC 5322 timestamps

    .DESCRIPTION
    Handles RFC 5322 Internet Message Format date-time specifications.
    Stores the timestamp as a DateTimeOffset to preserve timezone information.
    
    RFC 5322 format: [day-of-week ","] day month year time zone
    Example: "Sat, 03 Jan 2026 19:19:02 +0000"
    #>

    [DateTimeOffset]$DateTime
    [string]$RawValue


    #
    # Class Constructors
    #
    Timestamp() {
        <#
        .SYNOPSIS
        Default constructor for the Timestamp class
        #>
        # $this.DateTime = $null
        # $this.RawValue = $null
    }

    Timestamp([string]$rfc5322Date) {
        <#
        .SYNOPSIS
        Constructor that parses an RFC 5322 date string

        .PARAMETER rfc5322Date
        The date string in RFC 5322 format (e.g., "Sat, 03 Jan 2026 19:19:02 +0000")
        #>
        $this.RawValue = $rfc5322Date
        $this.ParseDate($rfc5322Date)
    }


    #
    # Methods
    #
    [void]ParseDate([string]$dateString) {
        <#
        .SYNOPSIS
        Parse an RFC 5322 date string into a DateTimeOffset

        .DESCRIPTION
        Handles RFC 5322 date format with optional day-of-week prefix.
        Supports timezone offsets like +0000, -0500, etc.
        Supports both zero-padded (03) and non-zero-padded (3) day formats.
        Format: [day-of-week ","] day month year time zone
        Example: "Sat, 03 Jan 2026 19:19:02 +0000" or "Sat, 3 Jan 2026 19:19:02 +0000"

        .PARAMETER dateString
        The RFC 5322 date string to parse
        #>
        
        if ([string]::IsNullOrWhiteSpace($dateString)) {
            throw [System.ArgumentException]::new("Date string cannot be null or empty")
        }

        # Remove the day-of-week prefix if present (e.g., "Sat, ")
        $cleanedDate = $dateString -replace '^\w+,\s*', ''
        
        # Normalize day to zero-padded format (e.g., "3" -> "03")
        # This handles RFC 5322 which allows both "3 Jan" and "03 Jan"
        $cleanedDate = $cleanedDate -replace '^(\d)\s', '0$1 '

        # Remove a "GMT" timezone with no offset
        $cleanedDate = $cleanedDate -replace '\sGMT$', ' +0000'

        # Remove any human-readable timezone names (e.g., "PST", "EST") if present
        $cleanedDate = $cleanedDate -replace '\s\(?[A-Z]{2,4}\)?$', ''
        
        # RFC 5322 date format: dd MMM yyyy HH:mm:ss zzz
        $format = 'dd MMM yyyy HH:mm:ss zzz'
        $culture = [System.Globalization.CultureInfo]::InvariantCulture
        
        try {
            $this.DateTime = [DateTimeOffset]::ParseExact(
                $cleanedDate,
                $format,
                $culture
            )
        }
        catch {
            throw [System.FormatException]::new(
                "Unable to parse date '$dateString' as RFC 5322 format",
                $_.Exception
            )
        }
    }


    #
    # Getters/Setters
    #
    [DateTimeOffset]getDateTime() {
        <#
        .SYNOPSIS
        Get the parsed datetime as a DateTimeOffset

        .OUTPUTS
        The DateTimeOffset value containing date, time, and timezone offset
        #>
        return $this.DateTime
    }

    [Timestamp]setDateTime([DateTimeOffset]$dateTime) {
        <#
        .SYNOPSIS
        Set the datetime value

        .PARAMETER dateTime
        The DateTimeOffset to set

        .OUTPUTS
        The current object (for method chaining)
        #>
        $this.DateTime = $dateTime
        $this.RawValue = $dateTime.ToString('ddd, dd MMM yyyy HH:mm:ss zzz')
        return $this
    }

    [string]getRawValue() {
        <#
        .SYNOPSIS
        Get the original RFC 5322 string

        .OUTPUTS
        The original date string as provided
        #>
        return $this.RawValue
    }

    [Timestamp]setRawValue([string]$value) {
        <#
        .SYNOPSIS
        Set the raw value and parse it

        .PARAMETER value
        The RFC 5322 date string to set and parse

        .OUTPUTS
        The current object (for method chaining)
        #>
        $this.RawValue = $value
        $this.ParseDate($value)
        return $this
    }


    #
    # Object Overrides
    #
    [string]ToString() {
        <#
        .SYNOPSIS
        Return the RFC 5322 formatted date string

        .OUTPUTS
        RFC 5322 formatted string (ddd, dd MMM yyyy HH:mm:ss +/-HHMM)
        #>
        if ($null -eq $this.DateTime) {
            return ''
        }
        
        # Format base datetime without timezone
        $baseFormat = $this.DateTime.ToString('ddd, dd MMM yyyy HH:mm:ss')
        $offsetFormat = $this.DateTime.ToString('zzz')
        $offsetFormat = $offsetFormat -replace ':', ''  # Remove colon from timezone offset
        
        return "$baseFormat $offsetFormat"
    }
}
