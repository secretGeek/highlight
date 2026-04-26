"";("echo 'hi' ","cls;","dir -rec | rel") | % { 
  show-code $_ -trailingNewLine:$false;
   wh (((" " * (25 - $_.length)) + " # ") + $_);} | out-null; "";