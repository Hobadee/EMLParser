Using Module ../../../../build/Imf/Imf.psm1


Describe 'PluginHeaderGeneric' {

    Context 'Constructors' {
        It 'Default constructor creates an instance' {
            $plugin = [PluginHeaderGeneric]::new()
            $plugin | Should -Not -BeNullOrEmpty
            $plugin -is [PluginHeaderGeneric] | Should -BeTrue
        }

        It 'Constructor with name and body creates an instance' {
            $plugin = [PluginHeaderGeneric]::new('X-Custom-Header', 'Some Value')
            $plugin | Should -Not -BeNullOrEmpty
            $plugin -is [PluginHeaderGeneric] | Should -BeTrue
        }

        It 'Constructor with name and body sets the name and body' {
            $plugin = [PluginHeaderGeneric]::new('X-Custom-Header', 'Some Value')
            $plugin.getName() | Should -Be 'X-Custom-Header'
            $plugin.getBodyRaw() | Should -Be 'Some Value'
        }
    }

    Context 'ParseBody method' {
        It 'ParseBody can be called without throwing an exception' {
            $plugin = [PluginHeaderGeneric]::new()
            $null = $plugin.setBody('Test Body')
            
            { $plugin.ParseBody() } | Should -Not -Throw
        }

        It 'ParseBody does nothing (no-op implementation)' {
            $plugin = [PluginHeaderGeneric]::new('X-Test', 'Original Body')
            $originalBody = $plugin.getBodyRaw()
            
            $plugin.ParseBody()
            
            # Body should remain unchanged
            $plugin.getBodyRaw() | Should -Be $originalBody
        }

        It 'ParseBody works with different header values' {
            $testValues = @('empty string', 'simple text', 'multi word value', 'special!@#$%chars')
            
            foreach ($value in $testValues) {
                $plugin = [PluginHeaderGeneric]::new('X-Test', $value)
                { $plugin.ParseBody() } | Should -Not -Throw
                $plugin.getBodyRaw() | Should -Be $value
            }
        }
    }

    Context 'Inherited behavior from PluginHeader' {
        It 'setName and getName work correctly' {
            $plugin = [PluginHeaderGeneric]::new()
            $null = $plugin.setName('X-Generic')
            
            $plugin.getName() | Should -Be 'X-Generic'
        }

        It 'setBody and getBody work correctly' {
            $plugin = [PluginHeaderGeneric]::new()
            $null = $plugin.setBody('   test  body   ')
            
            $plugin.getBody() | Should -Be 'test body'
            $plugin.getBodyRaw() | Should -Be 'test  body'
        }

        It 'ToString returns the expected format' {
            $plugin = [PluginHeaderGeneric]::new()
            $null = $plugin.setName('X-Generic')
            $null = $plugin.setBody('Header Value')
            
            $plugin.ToString() | Should -Be 'X-Generic: Header Value'
        }
    }

    Context 'Plugin registration and metadata' {
        # Can't parse this test for some reason - figure it out later
        # It 'fieldNames returns an array' {
        #     $names = [PluginHeaderGeneric]::fieldNames()
        #     $names | Should -BeOfType ([System.Object[]], [System.Collections.ArrayList])
        # }

        It 'fieldNames contains the wildcard "*"' {
            $names = [PluginHeaderGeneric]::fieldNames()
            $names | Should -Contain '*'
        }

        It 'fieldNames is registered in HeaderFieldPlugins' {
            $inst = [HeaderFieldPlugins]::GetInstance()
            $plugin = $inst.GetPluginForField('*')
            $plugin | Should -BeOfType ([PluginHeaderGeneric])
        }

        It 'Plugin can be instantiated through HeaderFieldPlugins registry' {
            $inst = [HeaderFieldPlugins]::GetInstance()
            $plugin = $inst.GetPluginForField('*')
            
            $plugin | Should -Not -BeNullOrEmpty
            $plugin -is [PluginHeaderGeneric] | Should -BeTrue
        }
    }

    Context 'Plugin behavior as a generic handler' {
        It 'Acts as a generic handler for any header field' {
            $plugin = [PluginHeaderGeneric]::new('X-Any-Header', 'Any Value')
            
            $plugin.getName() | Should -Be 'X-Any-Header'
            $plugin.getBodyRaw() | Should -Be 'Any Value'
        }

        It 'Preserves header data without modification' {
            $headerName = 'X-Preserved-Header'
            $headerValue = 'Preserved Value'
            
            $plugin = [PluginHeaderGeneric]::new($headerName, $headerValue)
            
            $plugin.getName() | Should -Be $headerName
            $plugin.getBodyRaw() | Should -Be $headerValue
        }

        It 'Works with whitespace-containing values' {
            $plugin = [PluginHeaderGeneric]::new('X-Whitespace', '  spaced  out  ')
            $plugin.getBodyRaw() | Should -Be '  spaced  out  '
        }

        It 'Works with empty string values' {
            $plugin = [PluginHeaderGeneric]::new('X-Empty', '')
            $plugin.getBodyRaw() | Should -Be ''
        }
    }

}
