<#
TODO: Plugins - Make a singleton to track plugin registration
                `New-Object -TypeName <class-name>`

#>




class ReceivedHeaderField : HeaderField {
    [string]$Timestamp
    [string]$Server

    ReceivedHeaderField([string]$name, [string]$body) : base($name, $body){
        <#
        .SYNOPSIS
        Use the parent constructor
        #>
    }

    [void]ParseBody() {
        # Extract timestamp and server from $this.Body
        $this.Timestamp = "Parsed Timestamp"
        $this.Server = "Parsed Server"
    }


    static [Array]fieldNames(){
        $names = @(
            "Received"
            "X-Received"
        )
        return $names
    }

}

class FromHeaderField : HeaderField {
    [string]$Name
    [Email]$Email

    FromHeaderField([string]$name, [string]$body) : base($name, $body){
        <#
        .SYNOPSIS
        Use the parent constructor
        #>
    }


    [void]ParseBody() {

        $search = '(?:(?<Name>.+)\s+)?<(?<Username>.+)@(?<Domain>.+)>'
        $regex = [regex]::new($search)

        $match = $regex.Matches($this.Body)

        $this.Name = $match[0].Groups["Name"].Value
        $Username = $match[0].Groups["Username"].Value
        $Domain = $match[0].Groups["Domain"].Value
        $this.Email = [Email]::new($Username, $Domain)
    }


    static [Array]fieldNames(){
        $names = @(
            "From"
        )
        return $names
    }

}
