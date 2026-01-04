# EML Parser Module
This PowerShell module will parse an EML file (raw storage of an [RFC5322](https://www.rfc-editor.org/rfc/rfc5322.html) message) and allow operations on it.

# Building
This project requires PoshCode ModuleBuilder to build.  (https://github.com/PoshCode/ModuleBuilder)

Install ModuleBuilder with:
`Install-Module ModuleBuilder -AllowPrerelease`

To build, simply run `Build-Module` in the project root.  On *NIX environments with `make`, you may run `make`.


# Testing
This project has Pester tests that can be run.  From the root of this project, simply run: `Invoke-Pester`
On *NIX environments with `make` installed, you may run `make test`

# TODO
## Plugin system for headers
Header parsing should be handled via a plugin system eventually.  Plugins will report what header names they operate on, and the header factory will pick which one to use based on that data

