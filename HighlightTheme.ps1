# Dotted and used by Get-TokenColor

## THEME definition
#
# Consider: an alternative file could be chosen by a "Theme Selector"
# (For full theming there would probably also be a single background color, set/reset at the top level)
# Note too that show-token performs some more specific color overwrites for quotes around strings, and comment hashes.
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