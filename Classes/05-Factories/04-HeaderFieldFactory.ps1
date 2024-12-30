class HeaderFieldFactory{

    static [HeaderField]CreateHeaderField([string]$name, [string]$body){

        $plugin = [HeaderFieldPlugins]::GetInstance().GetPluginForField($name)
        if ($null -ne $plugin){
            return $plugin::new($name, $body)
        }
        # No custom plugin found, use default plugin
        return [HeaderField]::new($name, $body)

    }

}
