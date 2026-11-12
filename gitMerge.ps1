<#
.SYNOPSIS
  Merges the configured upstream into the current branch with automatic stashing.

.DESCRIPTION
  With -WhatIf, checks committed-branch merge conflicts using git merge-tree --write-tree.
  The branch, index, working files, and stash are not changed, so no restoration is needed.
  Git may write unreachable merge objects. Conflicts when reapplying uncommitted changes
  with autostash are not checked. Requires Git with merge-tree --write-tree support.

.PARAMETER Branch
  Branch or commit to merge. Defaults to the configured upstream.

.EXAMPLE
  gitMerge.ps1 -WhatIf
  Checks whether merging the configured upstream would cause branch merge conflicts.

.EXAMPLE
  gitMerge.ps1 -Branch main -WhatIf
  Checks whether merging main would cause branch merge conflicts.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $Branch
)

. $PSScriptRoot\gitUtils.ps1

$mergeArgs = @('merge', '--autostash')
if ($Branch) { $mergeArgs += $Branch }
$shouldMerge = $PSCmdlet.ShouldProcess('Current branch', "git $($mergeArgs -join ' ')")

if ($WhatIfPreference) {
    $target = if ($Branch) { $Branch } else { '@{upstream}' }
    $targetCommit = RunGit rev-parse --verify --end-of-options "$target^{commit}" -NoLog
    $mergeOutput = @(RunGit merge-tree --write-tree --name-only HEAD $targetCommit -Silent)
    $mergeExitCode = $global:LastExitCode
    $mergeOutput | Select-Object -Skip 1 | ForEach-Object { Write-Host $_ }
    if ($mergeExitCode -eq 1) {
        throw "Merge conflicts detected when merging '$target' into the current branch."
    }
    if ($mergeExitCode -ne 0) {
        throw "'git merge-tree' returned code $mergeExitCode"
    }
    Write-Host "No branch merge conflicts detected when merging '$target' into the current branch."
} elseif ($shouldMerge) {
    RunGit @mergeArgs
}
