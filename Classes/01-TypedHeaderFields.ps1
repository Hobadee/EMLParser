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
    [string]$EmailAddress
    [string]$DisplayName

    FromHeaderField([string]$name, [string]$body) : base($name, $body){
        <#
        .SYNOPSIS
        Use the parent constructor
        #>
    }

    [void]ParseBody() {
        # Extract email and display name from $this.Body
        $this.EmailAddress = "Parsed Email"
        $this.DisplayName = "Parsed Name"
    }


    static [Array]fieldNames(){
        $names = @(
            "From"
        )
        return $names
    }

}
