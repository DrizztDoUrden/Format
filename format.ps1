#!/usr/bin/env pwsh

Param(
	[String]$Distro = "local",
	[String]$ClangFormat = "clang-format-12",
	[Switch]$WhatIf)

Set-Location $(git rev-parse --show-toplevel)

$commands = $input `
	| ? { Test-Path -PathType Leaf $_ } `
	| % { "$ClangFormat -i -style=file $_" }

if ($Distro -eq "local")
{
	if ($WhatIf) { return $commands }

	Import-Module SplitPipeline

	$input | Split-Pipeline -Variable commands `
	{ process {
		$file = $_
		& "$ClangFormat" -i "-style=file" $_
		if ($LASTEXITCODE -ne 0) { Write-Error "Error formating `"$_`"." }
	} }
}
else
{
	if ($WhatIf) { return $commands | % { "wsl --distribution $Distro --exec $_" } }

	wsl --distribution "$Distro" --exec $([String]::Join(" && ", $commands))
	if ($LASTEXITCODE -ne 0) { Write-Error "Error formating `"$file`"." }
}
