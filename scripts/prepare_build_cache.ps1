# Keep generated Android/Flutter build output outside a synchronized Desktop.
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$buildPath = [IO.Path]::GetFullPath((Join-Path $projectRoot 'build'))
if ($buildPath -ne (Join-Path $projectRoot 'build')) { throw 'Unexpected build path.' }
$cacheRoot = Join-Path $env:LOCALAPPDATA 'HealthMate'
$existing = Get-Item -LiteralPath $buildPath -Force -ErrorAction SilentlyContinue
if ($existing -and $existing.LinkType -eq 'Junction') {
    $target = [IO.Path]::GetFullPath([string](@($existing.Target)[0]))
    if (!$target.StartsWith([IO.Path]::GetFullPath($cacheRoot) + '\', [StringComparison]::OrdinalIgnoreCase)) {
        throw 'An existing build junction points to an unexpected location. Inspect it manually.'
    }
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    Write-Output "Local build cache ready: $target"
    exit 0
}
if ($existing -and $existing.LinkType) { throw 'An unexpected link already exists at build.' }
$hasher = [Security.Cryptography.SHA256]::Create()
try {
    $digest = [BitConverter]::ToString($hasher.ComputeHash([Text.Encoding]::UTF8.GetBytes($projectRoot.ToLowerInvariant()))).Replace('-', '').Substring(0, 12)
} finally { $hasher.Dispose() }
$target = Join-Path $cacheRoot ('build-' + $digest)
New-Item -ItemType Directory -Path $target -Force | Out-Null
if ($existing) {
    $backup = [IO.Path]::GetFullPath((Join-Path $projectRoot ('build-cache-backup-' + [guid]::NewGuid().ToString('N'))))
    if (!$backup.StartsWith($projectRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Unexpected backup path.' }
    Move-Item -LiteralPath $buildPath -Destination $backup
    Write-Output "Preserved old build cache: $backup"
}
New-Item -ItemType Junction -Path $buildPath -Target $target | Out-Null
Write-Output "Local build cache ready: $target"
