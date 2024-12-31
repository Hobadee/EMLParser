class Email {
    <#
    .SYNOPSIS
    Class to handle email addresses
    #>
    
    [string]$Username
    [string]$Domain


    Email([string]$email) {
        <#
        .SYNOPSIS
        Class constructor if you just have the entire email address
        #>

        $search = '^(?<username>.+)@(?<domain>.+)$'
        $regex = [regex]::new($search)

        $match = $regex.Matches($email)

        $this.Username = $match[0].Groups["username"].Value
        $this.Domain = $match[0].Groups["domain"].Value
    }

    Email([string]$Username, [string]$Domain){
        <#
        .SYNOPSIS
        Class constructor if you have the username and domain separately
        #>
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
