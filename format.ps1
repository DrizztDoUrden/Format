#!/usr/bin/env pwsh

Param(
	[String]$Distro = "local",
	[String]$ClangFormat = "clang-format-12",
	[Switch]$Log)

Import-Module SplitPipeline

$files = & "$PSScriptRoot/Diff-With.ps1" | ? { $_ -Match "\.h$|\.hpp$|\.c$|\.cpp$|\.h\.in$|\.hpp\.in$|\.cpp\.in$|\?CMakeLists.txt" }

$repoRoot = git rev-parse --show-toplevel

$files | Split-Pipeline -Variable repoRoot, Log, Distro, ClangFormat { process {
	$file = $_

	if (-not (Test-Path -PathType Leaf $file))
	{
		if ($Log) { Write-Host -ForegroundColor Cyan "File doesn't exist: `"$file`"`r" }
	}
	else
	{
		Set-Location $repoRoot
		if ($Distro -eq "local")
		{
			if ($Log) { Write-Host -ForegroundColor Cyan "$ClangFormat -i -style=file $file" }
			$out = & "$ClangFormat" -i "-style=file" $file
		}
		else
		{
			if ($Log) { Write-Host -ForegroundColor Cyan "wsl --distribution $Distro --exec $ClangFormat -i -style=file $file" }
			$out = wsl --distribution "$Distro" --exec "$ClangFormat" -i -style=file "$file"
		}

		if ($Log) { $out }
		if ($LASTEXITCODE -eq 0) { if ($Log) { "Finished formating `"$file`"." } }
		else { Write-Error "Error formating `"$file`"." }
	}
} }
