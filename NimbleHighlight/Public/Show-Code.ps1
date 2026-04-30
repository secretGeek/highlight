. (Join-Path (Join-Path $PSScriptRoot '..\Private') 'Get-Token.ps1')
. (Join-Path (Join-Path $PSScriptRoot '..\Private') 'Show-Token.ps1')

function Show-Code {
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$code = "",
		[switch]$trailingNewLine = $false
	)
	if ($code -eq "") { return; }

	Get-Token $code | Show-Token;
	if ($trailingNewLine) {
		Write-Host "";
	}
}
