. (Join-Path $PSScriptRoot "Get-TokenColor.ps1")
. (Join-Path $PSScriptRoot "Show-Name.ps1")


# Write a scrap of text, that is part of a token (may be the entire token)
function Write-Scrap($scrap, $token, $debugMode) {
	$tokenColor = (Get-TokenColor $token.Kind $token.TokenFlags $debugMode);
	$quoteColor = "Cyan";
	$dollarColor = "Cyan";
	$secondTokenColor = "DarkCyan";
	$commentHashColor = "Green";

	# Controversial! Write '$' and '#' (at start of Variable and Comment respectively)
	#  in a different color to the rest of the variable/comment.
	if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Variable -and
		$scrap -like '$*') {
		
		Write-Host '$' -ForegroundColor $dollarColor -NoNewline
		
		# Very *very* controversial -- different pascalCaseWordsAreDifferentColors !!
		Show-Name ($scrap.Substring(1)) -ForegroundColor $tokenColor -SecondForeGroundColor $secondTokenColor -NoNewline
	}
	elseif ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment -and
		$scrap -like '#*') {
		Write-Host '#' -ForegroundColor $commentHashColor -NoNewline
		Write-Host ($scrap.Substring(1)) -ForegroundColor $tokenColor -NoNewline
	}
	elseif (
		($token.Kind -eq [System.Management.Automation.Language.TokenKind]::StringExpandable -or
		$token.Kind -eq [System.Management.Automation.Language.TokenKind]::StringLiteral -or
		$token.Kind -eq [System.Management.Automation.Language.TokenKind]::HereStringExpandable) -and
		($scrap -like '"*' -or $scrap -like '*"' -or $scrap -like '''*' -or $scrap -like '*''')) {
		if ($scrap -like '"*' -or $scrap -like '''*') {
			Write-Host ($scrap.Substring(0, 1)) -ForegroundColor $quoteColor -NoNewline
		}
		else {
			Write-Host ($scrap.Substring(0, 1)) -ForegroundColor $tokenColor -NoNewline
		}
		if ($scrap -like '*"' -or $scrap -like '*''' -and $scrap.length -gt 1) {
			Write-Host ($scrap.Substring(1, $scrap.Length - 2)) -ForegroundColor $tokenColor -NoNewline
			Write-Host ($scrap.Substring($scrap.Length - 1)) -ForegroundColor $quoteColor -NoNewline
		}
		elseif ($scrap.length -gt 1) {
			Write-Host ($scrap.Substring(1)) -ForegroundColor $tokenColor -NoNewline
		}
	}
	else {
		Write-Host ($scrap) -ForegroundColor $tokenColor -NoNewline
	}
}

function Show-Token {
	Param(
		[Parameter(Mandatory,
			ValueFromPipeline = $true,
			HelpMessage = 'Tokens to be highlighted',
			Position = 0)]
		[System.Management.Automation.Language.Token[]]$Tokens,

		$charNumX,

		[bool]$debugMode = $false
	)
	Begin {
		$charNum = $host.UI.RawUI.CursorPosition.X;

		if ($null -ne $charNumX) {
			$charNum = $charNumX;
		}
		else {
			if ($charNum -eq 0) { $charNum = 1; }
		}
		$lineNum = 1;

		if ($null -ne $Tokens -and $Tokens[0].Extent.StartLineNumber -gt 1) {
			$lineNum = $Tokens[0].Extent.StartLineNumber;
		}
	}
	Process {
		ForEach ($token in $tokens) {
			#$tokenColor = (Get-TokenColor $token.Kind $token.TokenFlags $debugMode);

			if ($token.Extent.StartLineNumber -gt $lineNum) {
				$charNum = 1;
			}

			if ($token.Extent.StartColumnNumber -gt $charNum) {
				$numSpaces = ($token.Extent.StartColumnNumber - $charNum);

				Write-Host (" " * $numSpaces) -NoNewline;
				$charNum += $numSpaces;
			}

			if ($null -ne $token.NestedTokens) {

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

				$tokenStartOffset = $token.Extent.StartOffset;
				$upTo = $tokenStartOffset;
				ForEach ($innerToken in $token.NestedTokens) {
					if ($innerToken.Extent.StartOffset -gt $upTo) {
						# write the part of the 'outer token' that comes before the first nested token, or:
						# write the between:
						if ($token.Text.length -ge ($innerToken.Extent.StartOffset - $tokenStartOffset)) {
							#Write-Host ($token.Text.Substring($upTo - $tokenStartOffset, $innerToken.Extent.StartOffset - $upTo)) -f $tokenColor -n;
							Write-Scrap ($token.Text.Substring($upTo - $tokenStartOffset, $innerToken.Extent.StartOffset - $upTo)) $token $debugMode;
						}
						else {
							#Write-Host "XX" -f red -n; (wonder if this is end of input?)
						}
					}

					Show-Token $innerToken -charNumX:$innerToken.Extent.StartColumnNumber -debugMode:$debugMode;
					$upTo = $innerToken.Extent.EndOffset;
				}

				if ($upTo -lt ($token.Text.Length + $tokenStartOffset)) {
					# write the 'after' (see comment section above)
					Write-Scrap $token.Text.Substring($upTo - $tokenStartOffset) $token $debugMode;
				}
			}
			else {
				Write-Scrap $token.Text $token $debugMode;
			}

			$lineNum = $token.Extent.EndLineNumber;
			$charNum = $token.Extent.EndColumnNumber;
		};
	}
	End {
	}
}
