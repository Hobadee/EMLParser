Using Module ../../../build/Imf/Imf.psm1


Describe 'PluginHeader' {

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
	# 	$RepoRoot = Resolve-Path (Join-Path $ScriptDir '..' '..' '..')
		
    #     $files = @(
    #         (Join-Path $RepoRoot 'Classes\02-Header\01-HeaderField.ps1'),
    #         (Join-Path $RepoRoot 'Classes\02-Header\03-PluginHeader.ps1')
    #     )

    #     foreach ($f in $files) {
    #         . $f
    #     }
	# }

	Context 'Inheritance and basic behavior' {
		It 'supports setName/getName, setBody/getBody/getBodyRaw and ToString' {
			$ph = [PluginHeader]::new()

			$null = $ph.setName('X-Test')
			$null = $ph.setBody("  abc   def")

			$ph.getName() | Should -Be 'X-Test'
			$ph.getBodyRaw() | Should -Be 'abc   def'
			$ph.getBody() | Should -Be 'abc def'
			$ph.ToString() | Should -Be 'X-Test: abc def'
		}
	}

	Context 'Abstract methods and interface enforcement' {
		It 'ParseBody throws NotImplementedException when called directly' {
			$ph = [PluginHeader]::new()
			$didThrow = $false
			# We can't directly test `Should -Throw` inside the script block because of scoping issues
			try { $ph.ParseBody() } catch [System.NotImplementedException] { $didThrow = $true } catch { $didThrow = $false }
			$didThrow | Should -BeTrue
		}

		It 'fieldNames static method throws NotImplementedException' {
			$didThrow = $false
			# We can't directly test `Should -Throw` inside the script block because of scoping issues
			try { [PluginHeader]::fieldNames() } catch [System.NotImplementedException] { $didThrow = $true } catch { $didThrow = $false }
			$didThrow | Should -BeTrue
		}

		# Right now ParseBody() is also implemented in the HeaderField class
		It 'constructor that passes name/body triggers ParseBody and throws' {
			$didThrow = $false
			# We can't directly test `Should -Throw` inside the script block because of scoping issues
			try { [PluginHeader]::new('X','value') } catch [System.NotImplementedException] { $didThrow = $true }# catch { $didThrow = $false }
			$didThrow | Should -BeTrue
		}
	}

}
