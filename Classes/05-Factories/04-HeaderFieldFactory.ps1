class HeaderFieldFactory{

    static [HeaderField]CreateHeaderField([string]$name, [string]$body){

        $plugin = [HeaderFieldPlugins]::GetInstance().GetPluginForField($name)
        if ($null -eq $plugin){
            # Requested plugin not found, try generic plugin
            Write-Verbose("HeaderFieldFactory::CreateHeaderField() -  Plugin for '$name' not found, using generic plugin")
            $plugin = [HeaderFieldPlugins]::GetInstance().GetPluginForField("*")
        }
        if ($null -eq $plugin){
            Write-Error("Generic plugin not found.")
            throw [System.Collections.Generic.KeyNotFoundException]::New("HeaderFieldFactory::CreateHeaderField() -  No plugin found for header field '$name' and no generic plugin available.")
        }

        $plugin.setName($name)
        $plugin.setBody($body)
        $plugin.ParseBody()
        return $plugin
    }
}
