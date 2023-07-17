
## THEME definition
#
# Consider: These variables can be placed in a separate "Highlight_Theme.ps1" file, which is dotted.
# Thus, easy to modify theme -- and/or an alternative file could be chosen by a "Theme Selector"
# (For full theming there would probably also be a single background color, set/reset at the top level)
#
$h_NumberColor = [System.ConsoleColor]::White;
$h_VariableColor = [System.ConsoleColor]::Cyan; # Controversial. Some would have it Green;
$h_ParameterColor = [System.ConsoleColor]::DarkGray;
$h_CommentColor = [System.ConsoleColor]::Green;
$h_StringColor = [System.ConsoleColor]::DarkCyan;
$h_OperatorColor = [System.ConsoleColor]::DarkGray;
$h_CommandColor = [System.ConsoleColor]::Yellow;
$h_TypeNameColor = [System.ConsoleColor]::Gray;
$h_MemberColor = [System.ConsoleColor]::White;
$h_KeyWordColor = [System.ConsoleColor]::Green;
$h_IdentifierColor = [System.ConsoleColor]::Gray;
$h_GenericColor = [System.ConsoleColor]::Gray;
$h_RedirectionOperatorColor = [System.ConsoleColor]::White;
$h_UnrecognizedColor = [System.ConsoleColor]::Red;

# ^^ Theme.

function Get-TokenColor(
    [System.Management.Automation.Language.TokenKind]$tokenKind,
    [System.Management.Automation.Language.TokenFlags]$tokenFlags,
    $debugMode = $false) {

    if ($debugMode) {
        Write-Host "<# tk: $tokenKind, Tf: $tokenFlags #>" -f DarkMagenta -n;
    }

    # We need to test either, or both of these:
    # - [Enum]::GetValues([System.Management.Automation.Language.TokenKind])
    #       See: https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.language.tokenkind
    # - [Enum]::GetValues([System.Management.Automation.Language.TokenFlags])
    #       See: https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.language.tokenflags

    # First, we check the token kind...
    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Number) {
        return $h_NumberColor;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Variable) {
        return $h_VariableColor;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Parameter) {
        return $h_ParameterColor;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::SplattedVariable) {
        return $h_VariableColor;
    }

    ## A redirection operator such as '2>&1' or '>>'.
    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Redirection) {
        return $h_RedirectionOperatorColor;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::NewLine) {
        return $h_GenericColor; # Not really used, a new line is emmitted.
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Comment) {
        return $h_CommentColor;
    }

    # The 'param' keyword itself (VS Code incorrectly colors this, in this very code snippet!)
    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Param) {
        return $h_KeyWordColor;
    }

    # the `Function` keyword itself
    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Function) {
        return $h_KeyWordColor;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::StringExpandable -or
        $tokenKind -eq [System.Management.Automation.Language.TokenKind]::StringLiteral -or
        $tokenKind -eq [System.Management.Automation.Language.TokenKind]::HereStringExpandable
    ) {
        return $h_StringColor;
    }

    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::LBracket -or
        $tokenKind -eq [System.Management.Automation.Language.TokenKind]::RBracket) {
        return $h_OperatorColor;
    }

    # Now we switch to checking tokenFlags...

    # The token is one of the assignment operators: '=', '+=', '-=', '*=', '/=', '%=' or '??='
    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::AssignmentOperator)) {
        return $h_OperatorColor;
    }

    # UnaryOperator ++, --
    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::UnaryOperator)) {
        return $h_OperatorColor;
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::CommandName)) {
        return $h_CommandColor;
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::TypeName)) {
        return $h_TypeNameColor;
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::MemberName)) {
        return $h_MemberColor;
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::SpecialOperator)) {
        return $h_OperatorColor;
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::BinaryOperator)) {
        return $h_OperatorColor;
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::Keyword)) {
        return $h_KeyWordColor;
    }

    if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::ParseModeInvariant)) {
        return $h_OperatorColor; # consider: this was gray instead of darkgray before
    }

    # A simple identifier, always begins with a letter or '', and is followed by letters, numbers, or ''.
    # example: "-ErrorAction SilentlyContinue" -- the "SilentlyContinue" is such an identifier.
    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Identifier) {
        return $h_IdentifierColor;
    }

    # Last chance...
    if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::Generic) {
        return $h_GenericColor;
    }

    #  Unrecognised token... Was not colored....
    Write-Host "`n****`n****`n<# TokenKind: $tokenKind, TokenFlags: $tokenFlags #>" -f red -n;

    return $h_UnrecognizedColor;
}

<#
[Enum]::GetValues( [System.Management.Automation.Language.TokenKind] ) |
 % { return ('if ($tokenKind -eq [System.Management.Automation.Language.TokenKind]::' + "$_) {`n  # $_`n  return `$$($_)_color;`n}") }

 [Enum]::GetValues( [System.Management.Automation.Language.TokenFlags] ) |
 % { return ('if ($tokenFlags.HasFlag([System.Management.Automation.Language.TokenFlags]::' + "$_)) {`n  # $_`n  return `$$($_)_color;`n}") }

#>
