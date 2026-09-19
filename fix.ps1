$ErrorActionPreference = "Stop"
$gaId = "G-3L5I5CEKRL"
$clarityId = "ykk7rlhcr0"

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$bk = "_backup_$ts"
New-Item -ItemType Directory -Path $bk -Force | Out-Null
Write-Host "Backup: $bk" -ForegroundColor Cyan

$ana = @"
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

$e_ = "$([char]0x00E9)"
$o_ = "$([char]0x00F3)"
$a_ = "$([char]0x00E1)"
$i_ = "$([char]0x00ED)"
$u_ = "$([char]0x00FA)"
$n_ = "$([char]0x00F1)"
$E_ = "$([char]0x00C9)"
$O_ = "$([char]0x00D3)"
$U_ = "$([char]0x00DA)"
$N_ = "$([char]0x00D1)"
$q1 = "$([char]0x00BF)"
$q2 = "$([char]0x00A1)"
$deg = "$([char]0x00B0)"
$ap = "$([char]0x2019)"
$lq = "$([char]0x201C)"
$rq = "$([char]0x201D)"
$em = "$([char]0x2014)"
$en = "$([char]0x2013)"
$el = "$([char]0x2026)"

$me = "$([char]0x00C3)$([char]0x00A9)"
$mo = "$([char]0x00C3)$([char]0x00B3)"
$ma = "$([char]0x00C3)$([char]0x00A1)"
$mi = "$([char]0x00C3)$([char]0x00AD)"
$mu = "$([char]0x00C3)$([char]0x00BA)"
$mn = "$([char]0x00C3)$([char]0x00B1)"
$mE = "$([char]0x00C3)$([char]0x0089)"
$mO = "$([char]0x00C3)$([char]0x0093)"
$mU = "$([char]0x00C3)$([char]0x009A)"
$mN = "$([char]0x00C3)$([char]0x0091)"
$mq1 = "$([char]0x00C2)$([char]0x00BF)"
$mq2 = "$([char]0x00C2)$([char]0x00A1)"
$mdeg = "$([char]0x00C2)$([char]0x00B0)"
$map = "$([char]0x00E2)$([char]0x0080)$([char]0x0099)"
$mlq = "$([char]0x00E2)$([char]0x0080)$([char]0x009C)"
$mrq = "$([char]0x00E2)$([char]0x0080)$([char]0x009D)"
$mem = "$([char]0x00E2)$([char]0x0080)$([char]0x0094)"
$men = "$([char]0x00E2)$([char]0x0080)$([char]0x0093)"
$mel = "$([char]0x00E2)$([char]0x0080)$([char]0x00A6)"

$utf8 = New-Object System.Text.UTF8Encoding($false)
$files = Get-ChildItem -Path "." -Filter *.html -Recurse -File | Where-Object { $_.FullName -notmatch '_backup_' }
$total = $files.Count
$i = 0
$stA = 0; $stC = 0; $stM = 0; $stE = 0
$rootPath = (Resolve-Path ".").Path

foreach ($f in $files) {
    $i++
    Write-Progress -Activity "Procesando $total" -Status $f.Name -PercentComplete (($i/$total)*100)

    $rel = $f.FullName.Substring($rootPath.Length).TrimStart('\')
    $bp = Join-Path $bk $rel
    $bf = Split-Path $bp -Parent
    if (-not (Test-Path $bf)) { New-Item -ItemType Directory -Path $bf -Force | Out-Null }
    Copy-Item $f.FullName -Destination $bp -Force

    try { $c = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8) } catch { continue }
    $orig = $c

    $c = $c.Replace($me, $e_).Replace($mo, $o_).Replace($ma, $a_).Replace($mi, $i_).Replace($mu, $u_).Replace($mn, $n_)
    $c = $c.Replace($mE, $E_).Replace($mO, $O_).Replace($mU, $U_).Replace($mN, $N_)
    $c = $c.Replace($mq1, $q1).Replace($mq2, $q2).Replace($mdeg, $deg)
    $c = $c.Replace($map, $ap).Replace($mlq, $lq).Replace($mrq, $rq)
    $c = $c.Replace($mem, $em).Replace($men, $en).Replace($mel, $el)
    if ($c -ne $orig) { $stM++ }

    $bad = "Esc" + $i_ + "benos"
    $good = "Esc" + "r" + $i_ + "benos"
    if ($c.Contains($bad)) {
        $c = $c.Replace($bad, $good)
        $stE++
    }

    if ($c -notmatch '<meta\s+charset=["'']?UTF-8') {
        if ($c -match '<head[^>]*>') {
            $c = $c -replace '(<head[^>]*>)', ('$1' + [Environment]::NewLine + '<meta charset="UTF-8">')
            $stC++
        }
    }

    if ($c -notmatch 'googletagmanager\.com/gtag') {
        if ($c -match '</head>') {
            $c = $c -replace '</head>', ($ana + [Environment]::NewLine + '</head>')
            $stA++
        }
    }

    [System.IO.File]::WriteAllText($f.FullName, $c, $utf8)
}

Write-Progress -Activity "Procesando" -Completed
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  PROCESO COMPLETADO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Archivos totales:       $total"
Write-Host "  Analytics insertado:    $stA"
Write-Host "  Meta charset anadido:   $stC"
Write-Host "  Mojibake arreglado:     $stM"
Write-Host "  Escibenos corregido:    $stE"
Write-Host "  Backup:                 $bk" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Green