class HeaderFieldFactory{

    static [HeaderField]CreateHeaderField([string]$name, [string]$body){

        $plugin = [HeaderFieldPlugins]::GetInstance().GetPluginForField($name)
        if ($null -ne $plugin){
            $plugin.setName($name)
            $plugin.setBody($body)
            $plugin.ParseBody()
            return $plugin
        }
        # No custom plugin found, use default plugin
        return [HeaderField]::new($name, $body)

    }

}
