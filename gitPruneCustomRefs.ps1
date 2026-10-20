<#
.SYNOPSIS
  Deletes custom git refs (not branches or tags) that match a mask. Defaults to the agent checkpoint refs.

.DESCRIPTION
  Lists every ref in the current repository, keeps those whose full name matches -Mask (PowerShell -like
  wildcards, '*' also matches '/'), drops those matching -Exclude, and deletes the rest one at a time with
  'git update-ref -d'. A ref that fails to delete is reported and the others are still processed.

  Standard refs are never touched, whatever the mask: refs/heads/, refs/remotes/, refs/tags/, refs/stash,
  refs/notes/, refs/replace/. A mask that only matches those refs deletes nothing.

  Only local refs are deleted. The remote is not contacted.

  Run with -WhatIf first to see what would be removed. Without -Force a confirmation is requested.
  The commits the refs pointed to become unreachable and are removed by 'git gc'; use -Gc to expire and prune
  them now. This cannot be undone once pruned, so use -Exclude to keep refs of a session that is still running.

.PARAMETER Mask
  Wildcard for the full ref name. Default: refs/agents/*

.PARAMETER Exclude
  Wildcards for ref names to keep, e.g. '*80d37cbc-ab8b-4dc6-9284-8dbfec7a5621*'.

.PARAMETER Gc
  After deleting, run 'git reflog expire --expire-unreachable=now --all' and 'git gc --prune=now'.

.PARAMETER Force
  Do not ask for confirmation.

.EXAMPLE
  gitPruneCustomRefs.ps1 -WhatIf

.EXAMPLE
  gitPruneCustomRefs.ps1 -Exclude '*80d37cbc-ab8b-4dc6-9284-8dbfec7a5621*' -Force

.EXAMPLE
  gitPruneCustomRefs.ps1 -Mask 'refs/builds/*' -Gc
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [string] $Mask = 'refs/agents/*',
    [string[]] $Exclude = @(),
    [switch] $Gc,
    [switch] $Force
)

. $PSScriptRoot/gitUtils.ps1

$protectedPrefixes = @('refs/heads/', 'refs/remotes/', 'refs/tags/', 'refs/notes/', 'refs/replace/')
$protectedExact = @('refs/stash')

if (!(IsInsideWorkTree)) {
    throw 'Not inside a git work tree.'
}

$refs = @(RunGit for-each-ref '--format=%(refname)' -NoLog) |
    Where-Object { $_ -like $Mask } |
    Where-Object {
        $name = $_
        -not ($protectedExact -contains $name) -and
        -not ($protectedPrefixes | Where-Object { $name.StartsWith($_) }) -and
        -not ($Exclude | Where-Object { $name -like $_ })
    }

if (-not $refs) {
    Write-Host "No custom refs match '$Mask'. Nothing to do."
    return
}

$groups = @($refs | ForEach-Object { ($_ -split '/')[0..2] -join '/' } | Sort-Object -Unique)
Write-Host "Matched $($refs.Count) ref(s) in $($groups.Count) group(s) for mask '$Mask':"
foreach ($group in $groups) {
    $count = @($refs | Where-Object { $_.StartsWith("$group/") -or $_ -eq $group }).Count
    Write-Host "  $group ($count)"
}

if ($Force) { $ConfirmPreference = 'None' }
if (-not $PSCmdlet.ShouldProcess("$($refs.Count) ref(s) matching '$Mask'", 'Delete')) { return }

$deleted = 0
$failed = @()
foreach ($ref in $refs) {
    try {
        RunGit update-ref '-d' $ref -NoLog
        $deleted++
    } catch {
        $failed += $ref
        Write-Warning "Failed to delete ${ref}: $($_.Exception.Message)"
    }
}
Write-Host "Deleted $deleted of $($refs.Count) ref(s)."
if ($failed) {
    throw "Failed to delete $($failed.Count) ref(s)."
}

if ($Gc) {
    RunGit reflog expire --expire-unreachable=now --all
    RunGit gc --prune=now --quiet
    Write-Host 'Unreachable objects pruned.'
}
