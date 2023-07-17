# Highlight

This is a group of powershell cmdLets that let you syntax highlight Powershell Code, from powershell code and scripts.

## Show-Code

Example:

	show-code 'dir | % { $_.Name }'

Will display the code, `dir | % { $_.Name }`, with syntax highlighting.

The `Show-Code` function itself is very simple, and it's only significant line of code is this:

	Get-Token $code | Show-Token -debugMode:$debugMode;

i.e., it tokenizes the code that is passed to it, and asks the `Show-Token` cmdLet to write the tokens with syntax highlighting.


## Get-Token

`Get-token` is also very simple -- it only has 1 significant line of code:

	$result = [System.Management.Automation.Language.Parser]::ParseInput($code, [ref]$ParserTokens, [ref]$null) | Out-Null;

That is, all of its work is done by the `ParseInput` method in `Automation.Language.Parser`. This is a nifty tokenizer, built right into Powershell.

## Show-Token

Most of the work that `Show-Token` does is to do with special cases for "nested tokens". Once it knows the exact token or nested-token to be shown, it passes the result to a function `Write-Scrap` that then has to decide on the actual colors.

The following comment from `Show-Token` explains the tricky business of nested tokens. If we ignored the concept of Nested tokens, then a string such as `"Hello $world"` would be written in a single color -- the `$world` would be treated as a regular piece of text, not as an embedded expresion. Here is the comment to describe nested tokens:


	# NESTED TOKENS ARE FUN
    # Strings (and here-strings) can contain nested tokens (as do nested expressions)
    #
    # write-host "This is my name $myName and yours is $yourName I believe!"
    #            |-----------------outer token ----------------------------| <-- $token
    # write-host "This is my name $myName and yours is $yourName I believe!"
    #                             |--t1-|              |---t2--|             <-- $token.NestedTokens
    # write-host "This is my name $myName and yours is $yourName I believe!"
    #            |----between1----|     |---between2---|                     <-- between Nested tokens
    # write-host "This is my name $myName and yours is $yourName I believe!"
    #                                                           |---after--| <-- after Nested tokens
    #
    # Observations:
    # - there are as many 'betweens' as there are nested tokens.
    # - there is exactly 1 'after'.
    # - the quotes (which differ from string, to herestring etc.) are part of between1 and after.

## Write-Scrap

Ah -- now here is the controversial custom syntax highlighter itself.

Taking the lead from `VS Code`, and in contradistinction from other syntax highlighters, it does a little bit extra than writing a single token in a single color.

- Variable names that start with `$` -- the `$` is in a different color to the variable name.
- Comments that start with `#` -- the `#` is a different shade of green than the comment itself.
- Quoted strings, the quote marks themselves are in a different color than the string.
- Here-Strings -- the "@" at the start and end of the string is in a different color to the string.

But the **most controversial aspect of all** -- in `camelCase` and `PascalCase` variables names, each "word" is written in a slightly different color. In particular the colors alternate between cyan and darkcyan. The purpose here is to aid readability.

Here is how the terminal itself would syntax highlight a long pascal cased name:

![showCodeDefaultPSExample](showCodeDefaultPSExample.png)

Versus how this highlighter would do the same:

![showCodeNameExample](showCodeNameExample.png)


## To use these functions...

"Dot" the Show-Code file.

	. .\Show-Code.ps1

It will, in turn, dot the `Get-Token.ps1` and `Show-Token.ps1` files that it depends upon. And `Show-Token` will dot the `Get-TokenColor.ps1` and `Show-Name.ps1` files that it depends upon.

So you can use "All of it" by dotting "Show-Code" -- or just dot the part you need, if you only want "Show-Token" or "Get-TokenColor" or "Show-Name".

## Bonus -- PascalCase Word Splitter: Split-Pascalwise

To facilitate the coloring of words in camelCase and PascalCase variable names, there is handy cmdLet included:

- `Split-Pascalwise`

Given a string that contains a mixed of upper and lower case letters, it will split it into an array of word-like strings.

```powershell
> Split-Pascalwise 'ThisIsMyVariable123Help'
This
Is
My
Variable
123
Help
```

If you can't find some fun uses for a function like that, I honestly don't know what to tell you.

And since you're very curious (and why wouldn't you be) -- I'll share the regular expression at the heart of this thing.

```powershell
return ($_.ToString() -creplace '(?<!^)([A-Z0-9:_][a-z]|(?<=[a-z])[A-Z0-9:_])', ' $&').Split($null);
```

Note that it is case-sensitive (`creplace`) and it treats any switch from lower-case letters to "capital letters or numbers or ':' or '_'" as indicating a word boundary.

Some of the tricky cases that this treats as intended are:

```powershell
> Split-Pascalwise 'DVDExtras'
DVD
Extras
```

-- consecutive capitals are a single "word", until the last capital which is assumed to belong with the lower-case letters that follow it.

```powershell
> Split-Pascalwise 'AsEasyAs123'
As
Easy
As
123
```

...Numbers behave like capitals. A group of number together are one word.

But this also means, a following word that doesn't start with a capital, might 'steal' the last digit as its capital.

```powershell
> Split-Pascalwise '123guid'
12
3guid
```

