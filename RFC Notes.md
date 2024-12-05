RFC 5322

# Line Length
Max line length: 998 characters NOT including CRLF - 1000 including CRLF
78 characters (80 including CRLF) recommended

# Header Fields
- Begin with field name
- followed by colon (:)
- followed by field body
- terminated by CRLF

## Unstructured Field Bodies
- May be any printable ASCII+whitespace+folding
- Sounds like contents of X-Headers and whatnot

## Structured field bodies
- Structure defined by the RFC
- Things like the "From", "To", and "sender" fields

# Folding
- CRLF followed by WSP (space, tab)
- Only when allowed
- Technically can occur between any token, but should only occur in places that make sense, such as commas in comma separated lists
- Unfold by "s/[\r\n]\s+/ /"
- All folded fields should be parsed as unfolded

# Body
- Newlines MUST be CRLF
- 998/78 limit like headers
- MIME can break the 998/78 limit, but beyond scope of RFC5322

