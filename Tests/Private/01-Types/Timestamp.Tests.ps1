Using Module ../../../build/Imf/Imf.psm1


Describe 'Timestamp' {
    
    Context 'Constructor' {
        It 'default constructor creates empty Timestamp' {
            $ts = [Timestamp]::new()
            $ts.DateTime | Should -Be ([DateTimeOffset]::new(0001, 1, 1, 0, 0, 0, [TimeSpan]::Zero))
            $ts.RawValue | Should -BeNullOrEmpty
        }

        It 'constructor with RFC 5322 date string parses correctly' {
            $dateString = 'Sat, 03 Jan 2026 19:19:02 +0000'
            $ts = [Timestamp]::new($dateString)

            $ts.DateTime | Should -Not -BeNullOrEmpty
            $ts.RawValue | Should -Be $dateString
            $ts.DateTime.Year | Should -Be 2026
            $ts.DateTime.Month | Should -Be 1
            $ts.DateTime.Day | Should -Be 3
            $ts.DateTime.Hour | Should -Be 19
            $ts.DateTime.Minute | Should -Be 19
            $ts.DateTime.Second | Should -Be 2
        }
    }

    Context 'Parsing RFC 5322 dates' {
        It 'parses date with day-of-week prefix' {
            $ts = [Timestamp]::new('Sat, 03 Jan 2026 19:19:02 +0000')
            $ts.DateTime.DayOfWeek | Should -Be 'Saturday'
        }

        It 'parses date without day-of-week prefix' {
            $ts = [Timestamp]::new('03 Jan 2026 19:19:02 +0000')
            $ts.DateTime.Year | Should -Be 2026
            $ts.DateTime.Month | Should -Be 1
            $ts.DateTime.Day | Should -Be 3
        }

        It 'parses various day-of-week prefixes' {
            @('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun') | ForEach-Object {
                $dateString = "$_, 03 Jan 2026 19:19:02 +0000"
                $ts = [Timestamp]::new($dateString)
                $ts.DateTime.Year | Should -Be 2026
            }
        }

        It 'parses all month abbreviations' {
            @(
                @('Jan', 1), @('Feb', 2), @('Mar', 3), @('Apr', 4),
                @('May', 5), @('Jun', 6), @('Jul', 7), @('Aug', 8),
                @('Sep', 9), @('Oct', 10), @('Nov', 11), @('Dec', 12)
            ) | ForEach-Object {
                $month = $_[0]
                $monthNum = $_[1]
                $ts = [Timestamp]::new("03 $month 2026 19:19:02 +0000")
                $ts.DateTime.Month | Should -Be $monthNum
            }
        }

        It 'parses positive timezone offset (+0500)' {
            $ts = [Timestamp]::new('03 Jan 2026 19:19:02 +0500')
            $ts.DateTime.Offset | Should -Be ([TimeSpan]::FromHours(5))
        }

        It 'parses negative timezone offset (-0800)' {
            $ts = [Timestamp]::new('03 Jan 2026 19:19:02 -0800')
            $ts.DateTime.Offset | Should -Be ([TimeSpan]::FromHours(-8))
        }

        It 'parses UTC timezone (+0000)' {
            $ts = [Timestamp]::new('03 Jan 2026 19:19:02 +0000')
            $ts.DateTime.Offset | Should -Be ([TimeSpan]::Zero)
        }

        It 'parses half-hour timezone offset (+0530)' {
            $ts = [Timestamp]::new('03 Jan 2026 19:19:02 +0530')
            $ts.DateTime.Offset | Should -Be ([TimeSpan]::FromMinutes(330))
        }

        It 'parses time with seconds at 00' {
            $ts = [Timestamp]::new('03 Jan 2026 19:19:00 +0000')
            $ts.DateTime.Second | Should -Be 0
        }

        It 'parses time with seconds at 59' {
            $ts = [Timestamp]::new('03 Jan 2026 19:19:59 +0000')
            $ts.DateTime.Second | Should -Be 59
        }

        It 'parses 24-hour time format correctly' {
            @(
                @('00:00:00', 0, 0),
                @('12:30:45', 12, 30),
                @('23:59:59', 23, 59)
            ) | ForEach-Object {
                $time = $_[0]
                $expectedHour = $_[1]
                $expectedMin = $_[2]
                $ts = [Timestamp]::new("03 Jan 2026 $time +0000")
                $ts.DateTime.Hour | Should -Be $expectedHour
                $ts.DateTime.Minute | Should -Be $expectedMin
            }
        }
    }

    Context 'Error handling' {
        It 'throws FormatException for invalid date string' {
            { [Timestamp]::new('not-a-date') } | Should -Throw -ExceptionType ([System.FormatException])
        }

        It 'throws FormatException for malformed date' {
            { [Timestamp]::new('99 Jan 2026 19:19:02 +0000') } | Should -Throw -ExceptionType ([System.FormatException])
        }

        It 'throws FormatException for invalid month' {
            { [Timestamp]::new('03 Xyz 2026 19:19:02 +0000') } | Should -Throw -ExceptionType ([System.FormatException])
        }

        It 'throws FormatException for missing timezone' {
            { [Timestamp]::new('03 Jan 2026 19:19:02') } | Should -Throw -ExceptionType ([System.FormatException])
        }

        It 'throws ArgumentException for null date string' {
            { [Timestamp]::new([NullString]::Value) } | Should -Throw -ExceptionType ([System.ArgumentException])
        }

        It 'throws ArgumentException for empty date string' {
            { [Timestamp]::new('') } | Should -Throw -ExceptionType ([System.ArgumentException])
        }

        It 'throws ArgumentException for whitespace-only string' {
            { [Timestamp]::new('   ') } | Should -Throw -ExceptionType ([System.ArgumentException])
        }
    }

    Context 'Getters and setters' {
        It 'getDateTime returns the DateTimeOffset' {
            $ts = [Timestamp]::new('Sat, 03 Jan 2026 19:19:02 +0000')
            $dt = $ts.getDateTime()

            $dt | Should -BeOfType ([DateTimeOffset])
            $dt.Year | Should -Be 2026
        }

        It 'setDateTime updates the DateTime property' {
            $ts = [Timestamp]::new()
            $newDate = [DateTimeOffset]::new(2026, 1, 3, 19, 19, 2, [TimeSpan]::Zero)
            
            $ts.setDateTime($newDate)
            
            $ts.DateTime | Should -Be $newDate
        }

        It 'setDateTime returns $this for method chaining' {
            $ts = [Timestamp]::new()
            $newDate = [DateTimeOffset]::new(2026, 1, 3, 19, 19, 2, [TimeSpan]::Zero)
            
            $result = $ts.setDateTime($newDate)
            
            $result | Should -Be $ts
        }

        It 'getRawValue returns the original date string' {
            $dateString = 'Sat, 03 Jan 2026 19:19:02 +0000'
            $ts = [Timestamp]::new($dateString)
            
            $ts.getRawValue() | Should -Be $dateString
        }

        It 'setRawValue parses and updates the date' {
            $ts = [Timestamp]::new()
            $dateString = 'Sat, 03 Jan 2026 19:19:02 +0000'
            
            $ts.setRawValue($dateString)
            
            $ts.RawValue | Should -Be $dateString
            $ts.DateTime.Year | Should -Be 2026
        }

        It 'setRawValue returns $this for method chaining' {
            $ts = [Timestamp]::new()
            $dateString = 'Sat, 03 Jan 2026 19:19:02 +0000'
            
            $result = $ts.setRawValue($dateString)
            
            $result | Should -Be $ts
        }

        It 'setDateTime updates RawValue to formatted string' {
            $ts = [Timestamp]::new()
            $newDate = [DateTimeOffset]::new(2026, 1, 3, 19, 19, 2, [TimeSpan]::Zero)
            
            $ts.setDateTime($newDate)
            
            $ts.RawValue | Should -Match 'Sat, 03 Jan 2026 19:19:02'
        }
    }

    Context 'ToString method' {
        It 'returns RFC 5322 formatted string' {
            $ts = [Timestamp]::new('Sat, 03 Jan 2026 19:19:02 +0000')
            $result = $ts.ToString()

            $result | Should -Match 'Sat, 03 Jan 2026 19:19:02 \+0000'
        }

        # We cannot null a [DateTimeOffset], so this test is not applicable
        # It 'returns empty string for null DateTime' {
        #     $ts = [Timestamp]::new()
        #     $result = $ts.ToString()

        #     $result | Should -Be ''
        # }

        It 'preserves timezone in string output' {
            $ts = [Timestamp]::new('03 Jan 2026 19:19:02 -0500')
            $result = $ts.ToString()

            $result | Should -Match '\-0500'
        }
    }

    Context 'Method chaining' {
        It 'allows chaining multiple setter calls' {
            $date1 = [DateTimeOffset]::new(2026, 1, 3, 19, 19, 2, [TimeSpan]::Zero)
            $date2 = [DateTimeOffset]::new(2026, 1, 4, 20, 20, 3, [TimeSpan]::FromHours(-5))

            $ts = [Timestamp]::new()
            $result = $ts.setDateTime($date1).setDateTime($date2)

            $result | Should -Be $ts
            $ts.DateTime | Should -Be $date2
        }

        It 'allows chaining setDateTime with setRawValue' {
            $ts = [Timestamp]::new()
            $date = [DateTimeOffset]::new(2026, 1, 3, 19, 19, 2, [TimeSpan]::Zero)
            
            $result = $ts.setDateTime($date).setRawValue('03 Jan 2026 19:19:02 +0000')
            
            $result | Should -Be $ts
        }
    }

    Context 'Real-world examples' {
        It 'parses example from Humble Bundle email' {
            $ts = [Timestamp]::new('Sat, 03 Jan 2026 19:19:02 +0000')
            
            $ts.DateTime.Year | Should -Be 2026
            $ts.DateTime.Month | Should -Be 1
            $ts.DateTime.Day | Should -Be 3
            $ts.DateTime.Hour | Should -Be 19
            $ts.DateTime.Minute | Should -Be 19
            $ts.DateTime.Second | Should -Be 2
            $ts.DateTime.Offset | Should -Be ([TimeSpan]::Zero)
        }

        It 'parses US Eastern Standard Time' {
            $ts = [Timestamp]::new('Sat, 3 Jan 2026 11:19:03 -0800')
            
            $ts.DateTime.Offset | Should -Be ([TimeSpan]::FromHours(-8))
        }

        It 'parses Gmail timestamp format' {
            $ts = [Timestamp]::new('Mon, 1 Jan 2026 12:00:00 -0500')
            
            $ts.DateTime.Year | Should -Be 2026
            $ts.DateTime.DayOfWeek | Should -Be 'Thursday'
        }
    }
}
