param(
    [Parameter(Mandatory)] [string] $Message,
    [switch] $Pop
)

. $PSScriptRoot/gitUtils.ps1

$stashes = RunGit stash list --pretty=format:'%H|%gd|%gs'

$match = $stashes |
    Where-Object {
        $_ -match "^(?<hash>[0-9a-f]+)\|(?<ref>stash@\{\d+\})\|(?<msg>(?:On .*: )?$Message$)"
    } |
    Select-Object -First 1

if (-not $match) {
    Write-Error "No stash found containing message substring: '$Message'"
    exit 1
}

$hash = $matches.hash
$ref = $matches.ref
$msg = $matches.msg
Write-Host
    "Applying $($Pop ? 'and popping' : '') stash (Hash: $hash; Ref: $ref; Message: $msg)"
if ($Pop) {
    RunGit stash pop $hash
} else {
    RunGit stash apply $hash
}
