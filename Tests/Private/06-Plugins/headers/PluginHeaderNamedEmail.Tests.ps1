Using Module ../../../../build/Imf/Imf.psm1


Describe 'PluginHeaderNamedEmail' {

    # BeforeAll {
    #     $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    #     $RepoRoot = Resolve-Path (Join-Path $ScriptDir '..' '..' '..' '..')

    #     $files = @(
    #         (Join-Path $RepoRoot 'Classes\01-Types\Email.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\01-HeaderField.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\03-PluginHeader.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\01-HeaderFieldPlugins.ps1'),
    #         (Join-Path $RepoRoot 'Classes\06-Plugins\Headers\PluginHeaderNamedEmail.ps1')
    #     )

    #     foreach ($f in $files) {
    #         . $f
    #     }
    # }

    Context 'Parsing name and email' {
        It 'parses a named address' {
            $ph = [PluginHeaderNamedEmail]::new()
            $null = $ph.setBody('Alice Example <alice@example.com>')

            $ph.ParseBody()

            $ph.Name | Should -Be 'Alice Example'
            $ph.Email | Should -BeOfType ([Email])
            $ph.Email.getEmail() | Should -Be 'alice@example.com'
            $ph.Email.getUsername() | Should -Be 'alice'
            $ph.Email.getDomain() | Should -Be 'example.com'
        }

        It 'parses an address without a display name' {
            $ph = [PluginHeaderNamedEmail]::new()
            $null = $ph.setBody('<bob@domain.org>')

            $ph.ParseBody()

            $ph.Name | Should -Be ''
            $ph.Email.getEmail() | Should -Be 'bob@domain.org'
        }
    }

    Context 'Plugin metadata and registration' {
        It 'fieldNames contains From' {
            [PluginHeaderNamedEmail]::fieldNames() | Should -Contain 'From'
        }

        It 'HeaderFieldPlugins returns the plugin for From' {
            $inst = [HeaderFieldPlugins]::GetInstance()
            $plugin = $inst.GetPluginForField('From')
            $plugin | Should -BeOfType ([PluginHeaderNamedEmail])
        }

        It 'GetPluginForField returns $null for unknown fields' {
            $inst = [HeaderFieldPlugins]::GetInstance()
            $inst.GetPluginForField('X-Does-Not-Exist') | Should -Be $null
        }
    }

}
