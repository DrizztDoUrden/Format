#!/usr/bin/env pwsh

Param(
	[String]$With = "remotes/origin/develop",
	[String]$Filter = "\.h$|\.hpp$|\.c$|\.cpp$|\.h\.in$|\.hpp\.in$|\.cpp\.in$|\?CMakeLists.txt")

$files = git diff --name-only "$With..$(git rev-parse --abbrev-ref HEAD)"
$files += git clean -dn | % { $_.Substring(13) }

$files | ? { $_ -Match $Filter }
