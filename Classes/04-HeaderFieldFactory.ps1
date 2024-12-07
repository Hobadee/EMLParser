class HeaderFieldFactory{

    static [HeaderField]CreateHeaderField([string]$name, [string]$body){

        #Write-Debug("HeaderFieldFactory::CreateHeaderField()")

        # TODO: Make this plugin-able.
        # We should track all HeaderField types in an array and iterate looking
        # for a matching "name" from the fieldNames method

        switch ($name.ToLower()){
            "received" { return [ReceivedHeaderField]::new($name, $body) }
            "x-received" { return [ReceivedHeaderField]::new($name, $body) }
            "from" { return [FromHeaderField]::new($name, $body) }
            default { return [HeaderField]::new($name, $body) }
        }

        # PowerShell bitches if "I don't have a return path"
        # ...too dumb to realize "default" case will always return
        return [HeaderField]::new($name, $body)
    }

}
