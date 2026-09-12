param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference = 'Stop'
$resolved = (Resolve-Path -LiteralPath $Path).Path
$bytes = [IO.File]::ReadAllBytes($resolved)
if ($bytes.Length -lt 8 -or [BitConverter]::ToUInt32($bytes,0) -ne 2147483649) { throw 'Invalid container header' }
$count = [BitConverter]::ToUInt32($bytes,4)
if ($count -eq 0 -or $count -gt ($bytes.Length-8)/4) { throw 'Invalid index count' }
$offsets = @(for ($i=0; $i -lt $count; $i++) { [BitConverter]::ToUInt32($bytes,8+4*$i) })
$previous = 8+4*$count
foreach ($offset in $offsets) {
    if ($offset -lt $previous -or $offset -gt $bytes.Length) { throw 'Invalid index offset' }
    $previous = $offset
}
$issues = @()
$zeroEntries = 0
for ($i=0; $i -lt $count; $i++) {
    $start = $offsets[$i]
    $end = if ($i+1 -lt $count) { $offsets[$i+1] } else { $bytes.Length }
    if ($end-$start -lt 4) { throw "Truncated record $i" }
    $n = [BitConverter]::ToUInt32($bytes,$start)
    if ($n -gt ($end-$start-4)/6) { throw "Truncated arrays $i" }
    $last = 0
    for ($j=0; $j -lt $n; $j++) {
        $value = [BitConverter]::ToUInt16($bytes,$start+4+4*$n+2*$j)
        if ($value -lt $last) { throw "Nonmonotonic offsets $i" }
        $last = $value
    }
    if ($n -eq 0) { $zeroEntries++ }
    $bodyEnd = $start+4+6*$n+$last
    if ($bodyEnd -gt $end) { throw "Payload out of bounds $i" }
    if ($bodyEnd -ne $end) {
        $issues += [pscustomobject]@{ index=$i; offset=$start; entries=$n; trailingBytes=$end-$bodyEnd; trailingHex=[BitConverter]::ToString($bytes,$bodyEnd,$end-$bodyEnd) }
    }
}
[pscustomobject]@{ sha256=(Get-FileHash -LiteralPath $resolved -Algorithm SHA256).Hash; size=$bytes.Length; records=$count; zeroEntryRecords=$zeroEntries; unexplainedTails=$issues } | ConvertTo-Json -Depth 5
