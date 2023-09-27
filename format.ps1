#!/usr/bin/env pwsh

Param(
	[String]$Distro = "local",
	[String]$ClangFormat = "clang-format-12",
	[Switch]$WhatIf)

Set-Location $(git rev-parse --show-toplevel)

$commands = $input `
	| ? { Test-Path -PathType Leaf $_ } `
	| % { "$ClangFormat -i -style=file '$_'" }

if ($commands.Length -eq -0) { return }

if ($Distro -eq "local")
{
	if ($WhatIf) { return $commands }
	Import-Module SplitPipeline
	$input | Split-Pipeline { process { Invoke-Expression $_ } }
}
else
{
	$wslCommand = "wsl --distribution `"$Distro`" --exec `"trap 'kill 0' SIGINT; $([String]::Join(" & ", $commands)) & wait`""
	if ($WhatIf) { return $wslCommand }
	Invoke-Expression $wslCommand
}
