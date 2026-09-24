$file = "craft-nexus-contract\src\lib.rs"
$lines = Get-Content $file -Encoding UTF8

$result = [System.Collections.Generic.List[string]]::new()
$inConflict = $false
$keepHead = $true  # We always keep HEAD side for all 3 conflicts

foreach ($line in $lines) {
    if ($line -match '^<<<<<<< ') {
        $inConflict = $true
        $keepHead = $true   # start collecting HEAD side
        continue
    }
    if ($line -eq '=======' -and $inConflict) {
        $keepHead = $false  # switch to discarding (incoming side)
        continue
    }
    if ($line -match '^>>>>>>> ' -and $inConflict) {
        $inConflict = $false
        $keepHead = $true
        continue
    }
    if (-not $inConflict -or $keepHead) {
        $result.Add($line)
    }
}

$result | Set-Content $file -Encoding UTF8
Write-Host "Done. Lines after: $($result.Count)"
