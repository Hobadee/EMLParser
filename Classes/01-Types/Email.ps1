# Use [System.Net.Mail.MailAddress] instead

class Email {
    <#
    .SYNOPSIS
    Class to handle email addresses with optional name
    #>
    
    [string]$Username
    [string]$Domain
    [string]$Name


    Email([string]$email) {
        <#
        .SYNOPSIS
        Class constructor if you just have the entire email address

        .NOTES
        Parses the email address into username and domain components.
        Supports formats: "user@example.com" or "John Doe <user@example.com>"

        .THROWS
        [System.ArgumentNullException] If the email address is null or empty.
        [System.ArgumentException] If the email address is not in a valid format.
        [System.InvalidOperationException] If the email address has multiple matches.

        .EXAMPLE
        $email = [Email]::new("user@example.com")
        $email = [Email]::new("John Doe <user@example.com>")

        .PARAMETER email
        The full email address to parse, with optional name
        #>

        if ([string]::IsNullOrWhiteSpace($email)) {
            throw [System.ArgumentNullException]::New("Email address cannot be null or empty.")
        }

        $search = '^(?<username>.+)@(?<domain>.+)$'
        $regex = [regex]::new($search)

        $match = $regex.Matches($email)

        if ($match.Count -eq 0) {
            throw [System.ArgumentException]::New("Invalid email address format: $email")
        }
        if ($match.Count -gt 1) {
            # This should never happen, but just in case...
            throw [System.InvalidOperationException]::New("Multiple matches found for email address: $email")
        }

        $this.Username = $match[0].Groups["username"].Value.Trim()
        $this.Domain = $match[0].Groups["domain"].Value.Trim()
    }

    Email([string]$Username, [string]$Domain){
        <#
        .SYNOPSIS
        Class constructor if you have the username and domain separately

        .NOTES
        Sets the username and domain properties directly.

        .THROWS
        [System.ArgumentException] If the username or domain is not a string.

        .EXAMPLE
        $email = [Email]::new("user", "example.com")

        .PARAMETER Username
        The username portion of the email address

        .PARAMETER Domain
        The domain portion of the email address
        #>

        if ($Username -isnot [string]) {
            throw [System.ArgumentException]::New("Username must be a string.")
        }
        if ($Domain -isnot [string]) {
            throw [System.ArgumentException]::New("Domain must be a string.")
        }

        $this.Username = $Username
        $this.Domain = $Domain
    }


    [string]getEmail(){
        <#
        .SYNOPSIS
        Returns the full formatted email address
        #>
        $str = "$($this.Username)@$($this.Domain)"
        return $str
    }

    [string]getUsername(){
        <#
        .SYNOPSIS
        Returns just the username portion of the email address
        #>
        $str = $this.Username
        return $str
    }

    [string]getDomain(){
        <#
        .SYNOPSIS
        Returns just the domain portion of the email address
        #>
        $str = $this.Domain
        return $str
    }


    [string]ToString(){
        return $this.getEmail()
    }

}
