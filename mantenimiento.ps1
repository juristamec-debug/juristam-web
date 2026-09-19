# ============================================================
# SCRIPT DE MANTENIMIENTO JURISTAM
# GA4: G-3L5I5CEKRL
# Clarity: ykk7rlhcr0
# ============================================================

$ErrorActionPreference = "Stop"

$gaId      = "G-3L5I5CEKRL"
$clarityId = "ykk7rlhcr0"
$targetDir = "."

# --- CREAR BACKUP ---
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "_backup_$timestamp"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Write-Host "Backup en: $backupDir" -ForegroundColor Cyan

# --- SNIPPET DE ANALYTICS ---
$analytics = @"
<!-- Google Analytics 4 -->
<script async src="https://www.googletagmanager.com/gtag/js?id=$gaId"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', '$gaId');
</script>
<!-- Microsoft Clarity -->
<script type="text/javascript">
  (function(c,l,a,r,i,t,y){
    c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
    t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
    y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
  })(window, document, "clarity", "script", "$clarityId");
</script>
"@

# --- FUNCION PARA ARREGLAR MOJIBAKE ---
function Fix-Mojibake($text) {
    $pairs = @(
        @("Ã©", "é"), @("Ã³", "ó"), @("Ã¡", "á"), @("Ã­", "í"),
        @("Ãº", "ú"), @("Ã±", "ñ"), @("Ã‰", "É"), @("Ã“", "Ó"),
        @("Ãš", "Ú"), @("Ã‘", "Ñ"), @("Â¿", "¿"), @("Â¡", "¡"),
        @("Â°", "°"), @("Â", ""),
        @("â€™", "'"), @("â€œ", "`""), @("â€", "`""),
        @("â€”", "—"), @("â€“", "–"), @("â€¦", "…")
    )
    foreach ($pair in $pairs) {
        $text = $text.Replace($pair[0], $pair[1])
    }
    return $text
}

# --- PROCESAR ARCHIVOS ---
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$files = Get-ChildItem -Path $targetDir -Filter *.html -Recurse -File | Where-Object { $_.FullName -notmatch '_backup_' }
$total = $files.Count
$counter = 0
$stats = @{ Analytics = 0; Charset = 0; Mojibake = 0; Escibenos = 0; Total = $total }

$rootPath = (Resolve-Path $targetDir).Path

foreach ($file in $files) {
    $counter++
    Write-Progress -Activity "Procesando $total archivos" -Status $file.Name -PercentComplete (($counter / $total) * 100)

    # Backup
    $relativePath = $file.FullName.Substring($rootPath.Length).TrimStart('\')
    $backupPath = Join-Path $backupDir $relativePath
    $backupFolder = Split-Path $backupPath -Parent
    if (-not (Test-Path $backupFolder)) { New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null }
    Copy-Item $file.FullName -Destination $backupPath -Force

    # Leer como UTF-8
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    } catch {
        Write-Host "ERROR leyendo: $($file.Name)" -ForegroundColor Red
        continue
    }

    $originalContent = $content

    # 1. Arreglar mojibake
    $content = Fix-Mojibake $content
    if ($content -ne $originalContent) { $stats.Mojibake++ }

    # 2. Arreglar "Escíbenos" -> "Escríbenos"
    if ($content -match 'Esc[ií]benos') {
        $content = $content -replace 'Esc[ií]benos', 'Escríbenos'
        $content = $content -replace 'esc[ií]benos', 'escríbenos'
        $stats.Escibenos++
    }

    # 3. Asegurar meta charset UTF-8
    if ($content -notmatch '<meta\s+charset=["'']?UTF-8') {
        if ($content -match '<head[^>]*>') {
            $content = $content -replace '(<head[^>]*>)', "`$1`n<meta charset=`"UTF-8`">"
            $stats.Charset++
        }
    }

    # 4. Insertar Analytics si no existe
    if ($content -notmatch 'googletagmanager\.com/gtag') {
        if ($content -match '</head>') {
            $content = $content -replace '</head>', "$analytics`n</head>"
            $stats.Analytics++
        }
    }

    # 5. Guardar como UTF-8 sin BOM
    [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
}

Write-Progress -Activity "Procesando" -Completed
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  PROCESO COMPLETADO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Archivos totales:              $($stats.Total)"
Write-Host "  Analytics insertado en:        $($stats.Analytics)"
Write-Host "  Meta charset anadido en:       $($stats.Charset)"
Write-Host "  Mojibake arreglado en:         $($stats.Mojibake)"
Write-Host "  'Escibenos' corregido en:      $($stats.Escibenos)"
Write-Host "  Backup guardado en:            $backupDir" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Green