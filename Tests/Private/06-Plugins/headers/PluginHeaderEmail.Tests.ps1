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

            $ph.Email | Should -BeOfType ([Email])
            $ph.Email.getEmail() | Should -Be 'alice@example.com'
            $ph.Email.getUsername() | Should -Be 'alice'
            $ph.Email.getDomain() | Should -Be 'example.com'
        }

        # It 'Constructor that passes name/body triggers ParseBody' {
        #     $ph2 = [PluginHeaderEmail]::new('From','bob@domain.com')
        #     $ph2.Email | Should -BeOfType ([Email])
        #     $ph2.Email.getEmail() | Should -Be 'bob@domain.com'
        # }
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
