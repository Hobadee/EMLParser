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
        It 'parses all fields from a complete Received header' {
            $ph = [PluginHeaderReceived]::new()
            $body = 'from mail.example.com by mx.example.net with SMTP id ABC123; Tue, 1 Jan 2020 12:34:56 +0000'
            $null = $ph.setBody($body)

            $ph.ParseBody()

            $ph.From | Should -Be 'mail.example.com'
            $ph.By | Should -Be 'mx.example.net'
            $ph.IdType | Should -Be 'SMTP'
            $ph.Id | Should -Be 'ABC123'
            $ph.Timestamp | Should -Not -BeNullOrEmpty
        }

        It 'parses From field' {
            $ph = [PluginHeaderReceived]::new()
            $body = 'from sender.example.com by receiver.example.net; Tue, 1 Jan 2020 12:34:56 +0000'
            $null = $ph.setBody($body)

            $ph.ParseBody()

            $ph.From | Should -Be 'sender.example.com'
        }

        It 'parses By field' {
            $ph = [PluginHeaderReceived]::new()
            $body = 'from sender.example.com by receiver.example.net; Tue, 1 Jan 2020 12:34:56 +0000'
            $null = $ph.setBody($body)

            $ph.ParseBody()

            $ph.By | Should -Be 'receiver.example.net'
        }

        It 'parses IdType from with field' {
            $ph = [PluginHeaderReceived]::new()
            $body = 'from sender.example.com by receiver.example.net with HTTP id ABC123; Tue, 1 Jan 2020 12:34:56 +0000'
            $null = $ph.setBody($body)

            $ph.ParseBody()

            $ph.IdType | Should -Be 'HTTP'
        }

        It 'parses Id field' {
            $ph = [PluginHeaderReceived]::new()
            $body = 'from sender.example.com by receiver.example.net with SMTP id XYZ789; Tue, 1 Jan 2020 12:34:56 +0000'
            $null = $ph.setBody($body)

            $ph.ParseBody()

            $ph.Id | Should -Be 'XYZ789'
        }

        It 'parses Timestamp field' {
            $ph = [PluginHeaderReceived]::new()
            $body = 'from sender.example.com by receiver.example.net; 3 Jan 2026 11:19:00 -0800'
            $null = $ph.setBody($body)

            $ph.ParseBody()

            $ph.Timestamp | Should -Be 'Sat, 03 Jan 2026 11:19:00 -0800'
        }

        It 'constructor that passes name/body triggers ParseBody' {
            $ph2 = [PluginHeaderReceived]::new('Received', 'from mail.example.com by mx.example.net with SMTP id TEST123; Thu, 2 Jan 2020 10:20:30 +0000')
            
            $ph2.From | Should -Be 'mail.example.com'
            $ph2.By | Should -Be 'mx.example.net'
            $ph2.IdType | Should -Be 'SMTP'
            $ph2.Id | Should -Be 'TEST123'
            $ph2.Timestamp | Should -Be 'Thu, 02 Jan 2020 10:20:30 +0000'
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

        # It 'GetPluginForField throws KeyNotFoundException for unknown field' {
        #     $inst = [HeaderFieldPlugins]::GetInstance()
        #     { $inst.GetPluginForField('X-Unknown-Header') } | Should -Throw 'KeyNotFoundException'
        # }
    }

}
