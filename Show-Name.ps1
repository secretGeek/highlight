. (Join-Path $PSScriptRoot "Get-TokenColor.ps1")

# Javascript version:
# String.prototype.toWords = function (): string {
#     return this.replace(/([a-z])([A-Z])/gm, "$1 $2");
# };
# /([a-z])([A-Z])/gm, "$1 $2"

# Inspired by Steve Gilham here -- excellent work. https://stevegilham.blogspot.com/2011/06/splitting-pascal-cased-names-in.html
function Split-Pascalwise {
    $args | ForEach-Object {
        if ($_ -is [array]) {
            return ($_ | ForEach-Object { Split-Pascalwise $_ });
        }
        else {
            #return ($_.ToString() -creplace '[A-Z:_]', ' $&').Trim().Split($null);
            return ($_.ToString() -creplace '(?<!^)([A-Z0-9:_][a-z]|(?<=[a-z])[A-Z0-9:_])', ' $&').Split($null);
        }
    }
}


function Show-Name {
    Param(
        [Parameter(Mandatory,
            ValueFromPipeline = $true,
            HelpMessage = 'Name to be show',
            Position = 0)]
        [String]$Name,
        [Alias("f")][System.ConsoleColor]$ForeGroundColor = [ConsoleColor]::Cyan,
        [Alias("s")][System.ConsoleColor]$SecondForeGroundColor = [ConsoleColor]::DarkCyan,
        [Alias("N")][Switch]$NoNewLine = $null,
        [bool]$debugMode = $false
    )
    Begin {
        $private:i = 0;
    }
    Process {
        #Split it into words and use the two colors.
        #(Split-Pascalwise $Name | ForEach-Object { Write-Host "$_" -N -ForegroundColor $(if ($i++ % 2 -eq 0) { "Blue" } else { "DarkBlue" }); });
        Split-Pascalwise $Name | ForEach-Object {
            if ($debugMode) { Write-Host "i:$($private:i)" -NoNewline; }
            Write-Host "$_" -NoNewline -ForegroundColor $(if ($private:i++ % 2 -eq 0) { $ForeGroundColor } else { $SecondForeGroundColor });
        };
    }
    End {
    }
}
