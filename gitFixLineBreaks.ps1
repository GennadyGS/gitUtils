param(
    [switch] ${what-if}
)

. $PSScriptRoot/gitUtils.ps1

function Test-IsBinaryFile([string]$Path) {
    try {
        $stream = [System.IO.File]::OpenRead($Path)
        $buffer = New-Object byte[] 8000
        $read = $stream.Read($buffer, 0, $buffer.Length)
        $stream.Close()
        return ($buffer[0 .. ($read - 1)] -contains 0)
    } catch {
        return $true  # treat unreadable files as binary
    }
}

if (${what-if}) {
    Write-Host "Running in what-if mode. No changes will be applied."
}

RunGit ls-files |
Where-Object { Test-Path $_ } |
Where-Object { !(Test-IsBinaryFile $_) } |
Where-Object {
    $text = Get-Content -Raw -Encoding UTF8 $_
    if (!($text -match "(?<!`r)`n")) {
        return $false
    }

    if (-not ${what-if}) {
        $fixedText = $text -replace "(?<!`r)`n", "`r`n"
        Set-Content -Encoding UTF8 -NoNewline -Value $fixedText $_
    }

    return $true
}
