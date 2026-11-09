# poner-analytics.ps1
# Pone el codigo de Google Analytics en todas las paginas .html del sitio.
#  - Si la pagina ya lo tiene con un ID viejo, corrige el ID.
#  - Si no lo tiene, lo inserta justo antes de </head>.
#  - Si ya esta correcto, no la toca.
# Se ejecuta en la terminal de VS Code, parado en la carpeta del repo:
#   powershell -ExecutionPolicy Bypass -File .\poner-analytics.ps1

$ID   = 'G-JL51SCEKRL'
$raiz = (Get-Location).Path

$bloque = @"
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=$ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', '$ID');
</script>
"@

$utf8        = New-Object System.Text.UTF8Encoding($false)
$yaOk        = 0
$corregidos  = 0
$puestos     = 0
$sinHead     = 0
$listaSinHead = @()

Get-ChildItem -Path $raiz -Recurse -File -Include *.html,*.htm |
  Where-Object { $_.FullName -notmatch '\\(\.git|node_modules|\.github|vendor)\\' } |
  ForEach-Object {
      $ruta = $_.FullName
      $S    = [System.IO.File]::ReadAllText($ruta, $utf8)
      $orig = $S

      if ($S -match 'googletagmanager\.com/gtag/js') {
          $ids = @([regex]::Matches($S, 'G-[A-Z0-9]{6,12}') |
                   ForEach-Object { $_.Value } | Sort-Object -Unique)
          if ($ids.Count -eq 1 -and $ids[0] -eq $ID) { $script:yaOk++; return }
          foreach ($viejo in $ids) {
              if ($viejo -ne $ID) { $S = $S.Replace($viejo, $ID) }
          }
          $script:corregidos++
      }
      else {
          $m = [regex]::Match($S, '</head\s*>', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
          if (-not $m.Success) {
              $script:sinHead++
              $script:listaSinHead += $ruta
              return
          }
          $S = $S.Substring(0, $m.Index) + $bloque + "`n" + $S.Substring($m.Index)
          $script:puestos++
      }

      if ($S -ne $orig) { [System.IO.File]::WriteAllText($ruta, $S, $utf8) }
  }

Write-Host ""
Write-Host ("  ya estaban bien ........ {0}" -f $yaOk)
Write-Host ("  ID corregido ........... {0}" -f $corregidos)
Write-Host ("  codigo insertado ....... {0}" -f $puestos)
Write-Host ("  sin <head>, no tocados . {0}" -f $sinHead)
foreach ($r in $listaSinHead) { Write-Host ("      - {0}" -f $r) }
Write-Host ""
Write-Host ("  total de paginas con Analytics: {0}" -f ($yaOk + $corregidos + $puestos))
