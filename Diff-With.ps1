#!/usr/bin/env pwsh

Param([String]$With = "remotes/origin/develop")

$branch = git rev-parse --abbrev-ref HEAD

$files = git diff --name-only "$With..$branch"

$files += git clean -dn | % { $_.Substring(13) }

$files
