Using Module ../../../build/Imf/Imf.psm1

<###################################################################################################
 #                                                                                                 #
 # NOTE: This test appears to screw up other working tests by creating persistent singleton state. #
 #                                                                                                 #
 ###################################################################################################>


# Create a mock plugin for testing
class MockPluginHeader : PluginHeader {
    MockPluginHeader() : base() {}
    MockPluginHeader([string]$name, [string]$body) : base($name, $body) {}
    
    [void]ParseBody() {
        # Mock implementation
    }
    
    static [Array]fieldNames() {
        return @("X-Mock", "X-Test-Field")
    }
}

# Create another mock plugin for testing multiple registrations
class MockPluginHeaderAlt : PluginHeader {
    MockPluginHeaderAlt() : base() {}
    MockPluginHeaderAlt([string]$name, [string]$body) : base($name, $body) {}
    
    [void]ParseBody() {
        # Mock implementation
    }
    
    static [Array]fieldNames() {
        return @("X-Alternative", "X-Another-Field")
    }
}

# Create a non-plugin class for testing validation
class NotAPlugin {
    NotAPlugin() {}
}

Describe 'HeaderFieldPlugins' {
    
    Context 'Singleton pattern' {
        It 'GetInstance returns the same instance on multiple calls' {
            # Clear the singleton instance for this test
            [HeaderFieldPlugins]::Instance = $null
            
            $instance1 = [HeaderFieldPlugins]::GetInstance()
            $instance2 = [HeaderFieldPlugins]::GetInstance()
            
            $instance1 | Should -Not -BeNullOrEmpty
            $instance1 | Should -Be $instance2
        }

        It 'GetInstance creates an instance if one does not exist' {
            [HeaderFieldPlugins]::Instance = $null
            
            $instance = [HeaderFieldPlugins]::GetInstance()
            
            $instance | Should -Not -BeNullOrEmpty
            $instance -is [HeaderFieldPlugins] | Should -BeTrue
        }
    }

    Context 'Constructor' {
        It 'initializes PluginRegistry as a Dictionary' {
            [HeaderFieldPlugins]::Instance = $null
            $instance = [HeaderFieldPlugins]::new()
            
            $instance.PluginRegistry | Should -Not -BeNullOrEmpty
            $instance.PluginRegistry -is [System.Collections.Generic.Dictionary[string, [Type]]] | Should -BeTrue
        }

        It 'starts with an empty PluginRegistry' {
            [HeaderFieldPlugins]::Instance = $null
            $instance = [HeaderFieldPlugins]::new()
            
            $instance.PluginRegistry.Count | Should -Be 0
        }
    }

    Context 'RegisterPlugin' {
        BeforeEach {
            [HeaderFieldPlugins]::Instance = $null
        }

        It 'registers a valid plugin type' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            
            { $hfp.RegisterPlugin([MockPluginHeader]) } | Should -Not -Throw
        }

        It 'adds all field names from the plugin to the registry' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            $hfp.RegisterPlugin([MockPluginHeader])
            
            $hfp.PluginRegistry.ContainsKey("X-Mock") | Should -BeTrue
            $hfp.PluginRegistry.ContainsKey("X-Test-Field") | Should -BeTrue
        }

        It 'maps field names to the correct plugin type' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            $hfp.RegisterPlugin([MockPluginHeader])
            
            $hfp.PluginRegistry["X-Mock"] | Should -Be [MockPluginHeader]
            $hfp.PluginRegistry["X-Test-Field"] | Should -Be [MockPluginHeader]
        }

        It 'allows registering multiple plugin types' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            $hfp.RegisterPlugin([MockPluginHeader])
            $hfp.RegisterPlugin([MockPluginHeaderAlt])
            
            $hfp.PluginRegistry.Count | Should -Be 4
            $hfp.PluginRegistry.ContainsKey("X-Mock") | Should -BeTrue
            $hfp.PluginRegistry.ContainsKey("X-Alternative") | Should -BeTrue
        }

        It 'throws ArgumentException when registering a non-PluginHeader type' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            
            { $hfp.RegisterPlugin([NotAPlugin]) } | Should -Throw -ExceptionType ([ArgumentException])
        }

        It 'throws ArgumentException with appropriate message for invalid plugin' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            
            $exceptionThrown = $false
            $exceptionMessage = ""
            try {
                $hfp.RegisterPlugin([NotAPlugin])
            }
            catch [ArgumentException] {
                $exceptionThrown = $true
                $exceptionMessage = $_.Exception.Message
            }
            
            $exceptionThrown | Should -BeTrue
            $exceptionMessage | Should -Match "does not implement PluginHeader"
        }
    }

    Context 'GetPluginForField' {
        BeforeEach {
            [HeaderFieldPlugins]::Instance = $null
        }

        It 'returns a plugin instance for a registered field' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            $hfp.RegisterPlugin([MockPluginHeader])
            
            $plugin = $hfp.GetPluginForField("X-Mock")
            
            $plugin | Should -Not -BeNullOrEmpty
            $plugin -is [MockPluginHeader] | Should -BeTrue
        }

        It 'returns the correct plugin for multiple registered field names' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            $hfp.RegisterPlugin([MockPluginHeader])
            
            $plugin1 = $hfp.GetPluginForField("X-Mock")
            $plugin2 = $hfp.GetPluginForField("X-Test-Field")
            
            $plugin1 -is [MockPluginHeader] | Should -BeTrue
            $plugin2 -is [MockPluginHeader] | Should -BeTrue
        }

        It 'returns different instances for multiple calls to the same field' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            $hfp.RegisterPlugin([MockPluginHeader])
            
            $plugin1 = $hfp.GetPluginForField("X-Mock")
            $plugin2 = $hfp.GetPluginForField("X-Mock")
            
            $plugin1 | Should -Not -Be $plugin2
        }

        It 'returns null for an unregistered field' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            $hfp.RegisterPlugin([MockPluginHeader])
            
            $plugin = $hfp.GetPluginForField("X-Unknown")
            
            $plugin | Should -BeNullOrEmpty
        }

        It 'is case-sensitive when matching field names' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            $hfp.RegisterPlugin([MockPluginHeader])
            
            $plugin = $hfp.GetPluginForField("x-mock")
            
            $plugin | Should -BeNullOrEmpty
        }

        It 'returns the correct plugin when multiple plugins are registered' {
            $hfp = [HeaderFieldPlugins]::GetInstance()
            $hfp.RegisterPlugin([MockPluginHeader])
            $hfp.RegisterPlugin([MockPluginHeaderAlt])
            
            $plugin1 = $hfp.GetPluginForField("X-Mock")
            $plugin2 = $hfp.GetPluginForField("X-Alternative")
            
            $plugin1 -is [MockPluginHeader] | Should -BeTrue
            $plugin2 -is [MockPluginHeaderAlt] | Should -BeTrue
        }
    }

}
