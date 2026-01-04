Using Module ../../../../build/Imf/Imf.psm1


Describe 'PluginHeaderDate' {

    Context 'Constructor' {
        It 'default constructor creates empty PluginHeaderDate' {
            $plugin = [PluginHeaderDate]::new()
            
            $plugin.GetType() | Should -Be "PluginHeaderDate"
            $plugin.Name | Should -BeNullOrEmpty
            $plugin.Body | Should -BeNullOrEmpty
        }

        It 'constructor with name and RFC 5322 date parses correctly' {
            $dateString = 'Sat, 03 Jan 2026 19:19:02 +0000'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)

            $plugin.Name | Should -Be 'Date'
            $plugin.Body | Should -Be $dateString
            $plugin.Timestamp | Should -Not -BeNullOrEmpty
            $plugin.Timestamp.DateTime.Year | Should -Be 2026
        }
    }

    Context 'Parsing Date headers' {
        It 'parses standard RFC 5322 date with day-of-week' {
            $dateString = 'Sat, 03 Jan 2026 19:19:02 +0000'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            $plugin.Timestamp.DateTime.Year | Should -Be 2026
            $plugin.Timestamp.DateTime.Month | Should -Be 1
            $plugin.Timestamp.DateTime.Day | Should -Be 3
            $plugin.Timestamp.DateTime.Hour | Should -Be 19
            $plugin.Timestamp.DateTime.Minute | Should -Be 19
            $plugin.Timestamp.DateTime.Second | Should -Be 2
        }

        It 'parses date without day-of-week prefix' {
            $dateString = '03 Jan 2026 19:19:02 +0000'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            $plugin.Timestamp.DateTime.Year | Should -Be 2026
            $plugin.Timestamp.DateTime.Month | Should -Be 1
            $plugin.Timestamp.DateTime.Day | Should -Be 3
        }

        It 'parses date with single-digit day (non-padded)' {
            $dateString = 'Sat, 3 Jan 2026 19:19:02 +0000'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            $plugin.Timestamp.DateTime.Day | Should -Be 3
        }

        It 'parses date with negative timezone offset' {
            $dateString = 'Sat, 03 Jan 2026 19:19:02 -0500'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            $plugin.Timestamp.DateTime.Offset | Should -Be ([TimeSpan]::FromHours(-5))
        }

        It 'parses date with positive timezone offset' {
            $dateString = 'Sat, 03 Jan 2026 19:19:02 +0530'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            $plugin.Timestamp.DateTime.Offset | Should -Be ([TimeSpan]::FromMinutes(330))
        }

        It 'parses date with UTC timezone' {
            $dateString = 'Sat, 03 Jan 2026 19:19:02 +0000'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            $plugin.Timestamp.DateTime.Offset | Should -Be ([TimeSpan]::Zero)
        }

        It 'parses all month abbreviations' {
            @(
                @('Jan', 1), @('Feb', 2), @('Mar', 3), @('Apr', 4),
                @('May', 5), @('Jun', 6), @('Jul', 7), @('Aug', 8),
                @('Sep', 9), @('Oct', 10), @('Nov', 11), @('Dec', 12)
            ) | ForEach-Object {
                $month = $_[0]
                $monthNum = $_[1]
                $dateString = "03 $month 2026 19:19:02 +0000"
                $plugin = [PluginHeaderDate]::new('Date', $dateString)
                
                $plugin.Timestamp.DateTime.Month | Should -Be $monthNum
            }
        }

        It 'parses day-of-week correctly' {
            $dateString = 'Thu, 1 Jan 2026 12:00:00 +0000'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            $plugin.Timestamp.DateTime.DayOfWeek | Should -Be 'Thursday'
        }
    }

    Context 'Error handling' {
        It 'creates empty Timestamp for invalid date string' {
            $plugin = [PluginHeaderDate]::new('Date', 'not-a-date')
            
            # Empty Timestamp should have default DateTime
            $plugin.Timestamp.DateTime | Should -Be ([DateTimeOffset]::new(0001, 1, 1, 0, 0, 0, [TimeSpan]::Zero))
        }

        It 'creates empty Timestamp for malformed date' {
            $plugin = [PluginHeaderDate]::new('Date', '99 Jan 2026 19:19:02 +0000')
            
            # Empty Timestamp should have default DateTime
            $plugin.Timestamp.DateTime | Should -Be ([DateTimeOffset]::new(0001, 1, 1, 0, 0, 0, [TimeSpan]::Zero))
        }

        It 'creates empty Timestamp for date missing timezone' {
            $plugin = [PluginHeaderDate]::new('Date', '03 Jan 2026 19:19:02')
            
            # Empty Timestamp should have default DateTime
            $plugin.Timestamp.DateTime | Should -Be ([DateTimeOffset]::new(0001, 1, 1, 0, 0, 0, [TimeSpan]::Zero))
        }
    }

    Context 'fieldNames' {
        It 'returns array of handled field names' {
            $fieldNames = [PluginHeaderDate]::fieldNames()
            
            $fieldNames | Should -Contain 'Date'
            $fieldNames | Should -Contain 'X-Date'
        }

        It 'fieldNames returns string array' {
            $fieldNames = [PluginHeaderDate]::fieldNames()
            
            # The comma operator (,) before $fieldNames prevents PowerShell from unrolling the array when piping it to Should
            ,$fieldNames | Should -BeOfType [string[]]
        }
    }

    Context 'Real-world examples' {
        It 'parses Humble Bundle email date' {
            $dateString = 'Sat, 03 Jan 2026 19:19:02 +0000'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            $plugin.Timestamp.DateTime.Year | Should -Be 2026
            $plugin.Timestamp.DateTime.Month | Should -Be 1
            $plugin.Timestamp.DateTime.Day | Should -Be 3
            $plugin.Timestamp.DateTime.Hour | Should -Be 19
            $plugin.Timestamp.DateTime.Minute | Should -Be 19
            $plugin.Timestamp.DateTime.Second | Should -Be 2
        }

        It 'parses Gmail-style date with negative offset' {
            $dateString = 'Thu, 1 Jan 2026 12:00:00 -0800'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            $plugin.Timestamp.DateTime.Year | Should -Be 2026
            $plugin.Timestamp.DateTime.DayOfWeek | Should -Be 'Thursday'
            $plugin.Timestamp.DateTime.Offset | Should -Be ([TimeSpan]::FromHours(-8))
        }

        It 'parses date with unusual offset (+0545)' {
            $dateString = 'Wed, 15 Dec 2025 14:30:45 +0545'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            $plugin.Timestamp.DateTime.Offset | Should -Be ([TimeSpan]::FromMinutes(345))
        }

        It 'parses date at end of month' {
            $dateString = 'Fri, 31 Dec 2025 23:59:59 +0000'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            $plugin.Timestamp.DateTime.Day | Should -Be 31
            $plugin.Timestamp.DateTime.Month | Should -Be 12
            $plugin.Timestamp.DateTime.Year | Should -Be 2025
        }
    }

    Context 'Timestamp property' {
        It 'exposes Timestamp object with all parsed components' {
            $dateString = 'Sat, 03 Jan 2026 19:19:02 +0000'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            # Can't find type [Timestamp]...
            #$plugin.Timestamp | Should -BeOfType [Timestamp]
            $plugin.Timestamp.DateTime | Should -BeOfType [DateTimeOffset]
            $plugin.Timestamp.RawValue | Should -Be $dateString
        }

        It 'Timestamp can be used for further date manipulation' {
            $dateString = 'Sat, 03 Jan 2026 19:19:02 +0000'
            $plugin = [PluginHeaderDate]::new('Date', $dateString)
            
            # Test that we can access Timestamp methods
            $ts = $plugin.Timestamp
            $formatted = $ts.ToString()
            
            $formatted | Should -Match 'Sat, 03 Jan 2026 19:19:02'
        }
    }

    Context 'Header name handling' {
        It 'preserves header name as "Date"' {
            $plugin = [PluginHeaderDate]::new('Date', 'Sat, 03 Jan 2026 19:19:02 +0000')
            
            $plugin.Name | Should -Be 'Date'
        }

        It 'works with alternate header name "X-Date"' {
            $plugin = [PluginHeaderDate]::new('X-Date', 'Sat, 03 Jan 2026 19:19:02 +0000')
            
            $plugin.Name | Should -Be 'X-Date'
        }
    }
}
