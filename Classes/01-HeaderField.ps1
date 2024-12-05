class HeaderField{
    <#
    .SYNOPSIS
    Class to hold a header field

    .DESCRIPTION
    Used by the Header class to hold a single header field

    .NOTES
    We need a way of having multiple different Header Field types
    to handle things like routing headers, to/cc/bcc, etc...

    Maybe needs to be a strategy pattern?  This locks us into an interface though
    which we may not want - we may need to have flexible methods per type
    Is there a pattern that supports this?

    Possible patterns to look into:
    - Strategy
    - Template Method
    - Decorator (Probably not - used for multiple concurrent states of a single item)
    - State (Probably not - we aren't changing state of a single object)

    #>


    # Class variables
    hidden [String]$_name
    hidden [String]$_body


    #
    # Class Constructors
    #
    HeaderField(){
    }


    #
    # Getters/Setters
    #
    [HeaderField]setName([String]$name){
        $this._name = $name
        return $this
    }
    [String]getName(){
        return $this._name
    }


    [HeaderField]setBody([String]$body){
        $this._body = $body
        return $this
    }
    [String]getBody(){
        return $this._body
    }


    #
    # Magic Methods
    #
    [String]toString(){
        $rtn = $this._name + ": " + $this._body
        return $rtn
    }

}
