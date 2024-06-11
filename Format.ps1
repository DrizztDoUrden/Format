#!/usr/bin/env pwsh

Param(
	[String]$Distro = "local",
	[String]$ClangFormat = "clang-format-12",
	[Switch]$WhatIf,
	[Switch]$SingleThread,
	[Switch]$Diff)

Set-Location $(git rev-parse --show-toplevel)

$commands = $input `
	| % {
		if (Test-Path -PathType Leaf $_)
		{
			if ($Diff)
			{
				"& `"$ClangFormat`" -style=file '$_' | diff -p - $_"
			}
			else
			{
				"& `"$ClangFormat`" -i -style=file '$_'"
			}
		}
		else
		{
			Write-Warning "File doesn't exist: $_"
		}
	}

if ($commands.Length -eq -0)
{
	Write-Host "Nothing to format"
	return
}

if ($Distro -eq "local")
{
	if ($WhatIf) { return $commands }

	if ($SingleThread)
	{
		$commands | Invoke-Expression
	}
	else
	{
		$wd = Get-Location
		Import-Module SplitPipeline
		$commands | Split-Pipeline -Variable "wd" { process { Set-Location $wd; Invoke-Expression $_ } }
	}
}
else
{
	if ($SingleThread)
	{
		$wslCommand = "wsl --distribution `"$Distro`" --exec `"$([String]::Join(" && ", $commands))`""
	}
	else
	{
		$wslCommand = "wsl --distribution `"$Distro`" --exec `"trap 'kill 0' SIGINT; $([String]::Join(" & ", $commands)) & wait`""
	}

	if ($WhatIf) { return $wslCommand }
	Invoke-Expression $wslCommand
}
