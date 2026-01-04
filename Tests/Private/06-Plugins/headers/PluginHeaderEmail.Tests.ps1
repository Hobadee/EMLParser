Using Module ../../../../build/Imf/Imf.psm1


Describe 'PluginHeaderEmail' {

    # BeforeAll {
	# 	if ($PSScriptRoot) {
	# 		$ScriptDir = $PSScriptRoot
	# 	} elseif ($MyInvocation.MyCommand.Path) {
	# 		$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
	# 	} elseif ($PSCommandPath) {
	# 		$ScriptDir = Split-Path -Parent $PSCommandPath
	# 	} else {
	# 		$ScriptDir = (Get-Location).Path
	# 	}
    #     $RepoRoot = Resolve-Path (Join-Path $ScriptDir '..' '..' '..' '..')

    #     $files = @(
    #         (Join-Path $RepoRoot 'Classes\01-Types\Email.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\01-HeaderField.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\03-PluginHeader.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\01-HeaderFieldPlugins.ps1'),
    #         (Join-Path $RepoRoot 'Classes\06-Plugins\Headers\PluginHeaderEmail.ps1')
    #     )

    #     foreach ($f in $files) {
    #         . $f
    #     }
    # }

    Context 'Parsing email addresses' {
        It 'ParseBody extracts Email when called explicitly' {
            $ph = [PluginHeaderEmail]::new()
            $null = $ph.setBody('alice@example.com')

            $ph.ParseBody()

            $ph.Email | Should -BeOfType ([System.Net.Mail.MailAddress])
            $ph.Email.Address | Should -Be 'alice@example.com'
            $ph.Email.User | Should -Be 'alice'
            $ph.Email.Host | Should -Be 'example.com'
        }

        # It 'Constructor that passes name/body triggers ParseBody' {
        #     $ph2 = [PluginHeaderEmail]::new('From','bob@domain.com')
        #     $ph2.Email | Should -BeOfType ([Email])
        #     $ph2.Email.getEmail() | Should -Be 'bob@domain.com'
        # }
    }

    Context 'Parsing multiple email addresses' {
        It 'ParseBody extracts multiple comma-separated email addresses' {
            $ph = [PluginHeaderEmail]::new()
            $null = $ph.setBody('alice@example.com, bob@domain.com')

            $ph.ParseBody()

            $ph.Emails | Should -HaveCount 2
            $ph.Emails[0].Address | Should -Be 'alice@example.com'
            $ph.Emails[1].Address | Should -Be 'bob@domain.com'
        }

        It 'ParseBody extracts multiple addresses with display names' {
            $ph = [PluginHeaderEmail]::new()
            $null = $ph.setBody('Alice Smith <alice@example.com>, Bob Johnson <bob@domain.com>')

            $ph.ParseBody()

            $ph.Emails | Should -HaveCount 2
            $ph.Emails[0].Address | Should -Be 'alice@example.com'
            $ph.Emails[0].DisplayName | Should -Be 'Alice Smith'
            $ph.Emails[1].Address | Should -Be 'bob@domain.com'
            $ph.Emails[1].DisplayName | Should -Be 'Bob Johnson'
        }

        It 'ParseBody handles mixed email addresses with and without display names' {
            $ph = [PluginHeaderEmail]::new()
            $null = $ph.setBody('Alice Smith <alice@example.com>, bob@domain.com, "Charlie Brown" <charlie@test.org>')

            $ph.ParseBody()

            $ph.Emails | Should -HaveCount 3
            $ph.Emails[0].Address | Should -Be 'alice@example.com'
            $ph.Emails[0].DisplayName | Should -Be 'Alice Smith'
            $ph.Emails[1].Address | Should -Be 'bob@domain.com'
            $ph.Emails[2].Address | Should -Be 'charlie@test.org'
            $ph.Emails[2].DisplayName | Should -Be 'Charlie Brown'
        }

        It 'ParseBody trims whitespace around comma-separated addresses' {
            $ph = [PluginHeaderEmail]::new()
            $null = $ph.setBody('alice@example.com  ,  bob@domain.com  ,  charlie@test.org')

            $ph.ParseBody()

            $ph.Emails | Should -HaveCount 3
            $ph.Emails[0].Address | Should -Be 'alice@example.com'
            $ph.Emails[1].Address | Should -Be 'bob@domain.com'
            $ph.Emails[2].Address | Should -Be 'charlie@test.org'
        }
    }

    Context 'Plugin registration and metadata' {
        It 'fieldNames contains Delivered-To' {
            [PluginHeaderEmail]::fieldNames() | Should -Contain 'Delivered-To'
        }

        It 'HeaderFieldPlugins returns the plugin for Delivered-To' {
            $inst = [HeaderFieldPlugins]::GetInstance()
            $plugin = $inst.GetPluginForField('Delivered-To')
            $plugin | Should -BeOfType ([PluginHeaderEmail])
        }

        It 'GetPluginForField returns $null for unknown fields' {
            $inst = [HeaderFieldPlugins]::GetInstance()
            $inst.GetPluginForField('X-Does-Not-Exist') | Should -Be $null
        }
    }

}
