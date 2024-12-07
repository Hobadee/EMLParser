# EML Parser Module
This PowerShell module will parse an EML file (raw storage of an RFC5322 message) and allow operations on it.

# TODO
## Plugin system for headers
Header parsing should be handled via a plugin system eventually.  Plugins will report what header names they operate on, and the header factory will pick which one to use based on that data

