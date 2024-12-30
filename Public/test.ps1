function test{
        [CmdletBinding()]
        param (
        )

        $data = Get-Content -Raw ./testEmail.eml

        $imf = [Imf]::new()
        $imf.setRawData($data)

        # $imf.parseHeaders()

        # Supidity to return an *ACTUAL* "Imf" object
        # PWSH is "enumerating" the object into a base object
        # Downside to this stupid: We need to reference: $imf.Imf.
        return ,([pscustomobject]@{ Imf = $imf })
}
