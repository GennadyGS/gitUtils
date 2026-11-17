<#
.SYNOPSIS
  Pulls the current branch, merges a source branch, and pushes the result.

.DESCRIPTION
  Uses the current branch's configured pull and push destinations.
  The source can be a local branch or remote-tracking ref. It is merged as-is;
  git pull only fetches according to the current branch's remote configuration.
  Stops on the first error, leaving any merge conflicts for manual resolution.

.PARAMETER SourceBranch
  Source branch to merge into the current branch.

.EXAMPLE
  gitUpdateBranch.ps1 -SourceBranch origin/main
#>
param(
    [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [string] $SourceBranch
)

$ErrorActionPreference = 'Stop'

. $PSScriptRoot\gitUtils.ps1

RunGit pull
RunGit merge --no-edit $SourceBranch
RunGit push
