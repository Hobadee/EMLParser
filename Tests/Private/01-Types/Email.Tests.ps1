Using Module ../../../build/Imf/Imf.psm1


Describe "Email Class Tests" {
    Context "Constructor with full email address" {
        It "Should correctly parse the username and domain from the email address" {
            $email = [Email]::new("user@example.com")
            $email.Username | Should -Be "user"
            $email.Domain | Should -Be "example.com"
        }

        It "Should throw an error for invalid email address" {
            { [Email]::new("invalid-email") } | Should -Throw
        }
    }

    Context "Constructor with username and domain" {
        It "Should correctly set the username and domain" {
            $email = [Email]::new("user", "example.com")
            $email.Username | Should -Be "user"
            $email.Domain | Should -Be "example.com"
        }
    }

    Context "getEmail method" {
        It "Should return the full email address" {
            $email = [Email]::new("user", "example.com")
            $email.getEmail() | Should -Be "user@example.com"
        }
    }

    Context "getUsername method" {
        It "Should return the username" {
            $email = [Email]::new("user", "example.com")
            $email.getUsername() | Should -Be "user"
        }
    }

    Context "getDomain method" {
        It "Should return the domain" {
            $email = [Email]::new("user", "example.com")
            $email.getDomain() | Should -Be "example.com"
        }
    }

    Context "ToString method" {
        It "Should return the full email address" {
            $email = [Email]::new("user", "example.com")
            $email.ToString() | Should -Be "user@example.com"
        }
    }
}
