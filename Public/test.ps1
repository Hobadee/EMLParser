function test{
        [CmdletBinding(SupportsShouldProcess=$true)]
        param (
        )
        
        $data = Get-Content -Raw ./testEmail.eml

        $imf = [Imf]::new()
        $imf.setRawData($data)

        $imf.unfold()
        $imf.parseHeaders()

        return $imf
}
