Using Module ../../../../build/Imf/Imf.psm1


Describe 'PluginHeaderList' {

    # BeforeAll {
    #     $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    #     $RepoRoot = Resolve-Path (Join-Path $ScriptDir '..' '..' '..' '..')

    #     $files = @(
    #         (Join-Path $RepoRoot 'Classes\01-Types\Email.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\01-HeaderField.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\03-PluginHeader.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\01-HeaderFieldPlugins.ps1'),
    #         (Join-Path $RepoRoot 'Classes\06-Plugins\Headers\PluginHeaderList.ps1')
    #     )

    #     foreach ($f in $files) {
    #         . $f
    #     }
    # }

    Context 'Parsing List-* headers' {
        It 'parses mailto then url parts' {
            $ph = [PluginHeaderList]::new()
            $body = 'List-Post: <mailto:groupname@example.com>, <https://groups.google.com/a/example.com/group/groupname/>'
            $null = $ph.setBody($body)

            $ph.ParseBody()

            $ph.ListType | Should -Be 'Post'
            $ph.ListEmail | Should -BeOfType ([System.Net.Mail.MailAddress])
            $ph.ListEmail.Address | Should -Be 'groupname@example.com'
            $ph.ListUrl | Should -Be 'https://groups.google.com/a/example.com/group/groupname/'
        }

        It 'parses a single URL-only List-Help' {
            $ph = [PluginHeaderList]::new()
            $body = 'List-Help: <https://support.example.com>'
            $null = $ph.setBody($body)

            $ph.ParseBody()

            $ph.ListType | Should -Be 'Help'
            $ph.ListUrl | Should -Be 'https://support.example.com'
            $ph.ListEmail | Should -Be $null
        }

        It 'constructor that passes name/body triggers ParseBody' {
            $ph2 = [PluginHeaderList]::new('List-Archive','List-Archive: <mailto:archive@example.com>')
            $ph2.ListType | Should -Be 'Archive'
            $ph2.ListEmail | Should -BeOfType ([System.Net.Mail.MailAddress])
            $ph2.ListEmail.Address | Should -Be 'archive@example.com'
        }
    }

    Context 'Plugin registration and metadata' {
        It 'fieldNames contains List-Post' {
            [PluginHeaderList]::fieldNames() | Should -Contain 'List-Post'
        }

        It 'HeaderFieldPlugins returns the plugin for List-Post' {
            $inst = [HeaderFieldPlugins]::GetInstance()
            $plugin = $inst.GetPluginForField('List-Post')
            $plugin | Should -BeOfType ([PluginHeaderList])
        }
    }

}
