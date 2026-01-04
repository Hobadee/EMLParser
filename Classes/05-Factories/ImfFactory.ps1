class ImfFactory {

    static [Imf] CreateImfFromFile([string] $filePath) {
        $imf = [Imf]::new()

        try {
            $data = Get-Content -Raw $filePath
        }
        catch {
            throw [System.IO.IOException]::New("Could not read file at path '$filePath'.")
        }

        try {
            $imf.setRawData($data)
        }
        catch {
            throw [System.FormatException]::New("Could not parse IMF data from file '$filePath'.")
        }

        return $imf
    }
}
