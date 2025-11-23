Using Module ../../../../build/Imf/Imf.psm1


Describe 'PluginHeaderReceived' {

    # BeforeAll {
    #     $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    #     $RepoRoot = Resolve-Path (Join-Path $ScriptDir '..' '..' '..' '..')

    #     $files = @(
    #         (Join-Path $RepoRoot 'Classes\01-Types\Email.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\01-HeaderField.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\03-PluginHeader.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\01-HeaderFieldPlugins.ps1'),
    #         (Join-Path $RepoRoot 'Classes\06-Plugins\Headers\PluginHeaderReceived.ps1')
    #     )

    #     foreach ($f in $files) {
    #         . $f
    #     }
    # }

    Context 'Parsing Received header' {
        It 'ParseBody sets Timestamp and Server when called explicitly' {
            $ph = [PluginHeaderReceived]::new()
            $null = $ph.setBody('from mail.example.com by mx.example.net; Tue, 1 Jan 2020 12:34:56 +0000')

            $ph.ParseBody()

            $ph.Timestamp | Should -Be 'Parsed Timestamp'
            $ph.Server | Should -Be 'Parsed Server'
        }

        It 'constructor that passes name/body triggers ParseBody' {
            $ph2 = [PluginHeaderReceived]::new('Received','received value')
            $ph2.Timestamp | Should -Be 'Parsed Timestamp'
            $ph2.Server | Should -Be 'Parsed Server'
        }
    }

    Context 'Plugin registration and metadata' {
        It 'fieldNames contains Received and X-Received' {
            [PluginHeaderReceived]::fieldNames() | Should -Contain 'Received'
            [PluginHeaderReceived]::fieldNames() | Should -Contain 'X-Received'
        }

        It 'HeaderFieldPlugins returns the plugin for Received' {
            $inst = [HeaderFieldPlugins]::GetInstance()
            $plugin = $inst.GetPluginForField('Received')
            $plugin | Should -BeOfType ([PluginHeaderReceived])
        }

        It 'GetPluginForField returns $null for an unknown field' {
            $inst = [HeaderFieldPlugins]::GetInstance()
            $inst.GetPluginForField('X-Unknown-Header') | Should -Be $null
        }
    }

}
