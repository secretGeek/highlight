. (Join-Path $PSScriptRoot "Get-Token.ps1")
. (Join-Path $PSScriptRoot "Show-Token.ps1")

function Show-Code {
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string]
		$code = "",
		$debugMode = $false
	)
	if ($code -eq "") { return; }

	Get-Token $code | Show-Token -debugMode:$debugMode;
}
