$ErrorActionPreference = "Continue"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$swv  = "C:\872C~1\PLATIN~1\sw.js"

Write-Output "=== 1) что сейчас в sw.js на ДИСКЕ (версия кэша) ==="
$sw = $null
if (Test-Path -LiteralPath $swv) { $sw = Get-Content $swv -Raw -Encoding UTF8 }
if ($sw) {
  "sw на диске: байт = " + $sw.Length
  ($sw -split '\r?\n' | Select-String -Pattern 'CACHE|VERSION|cache=' ) -join "`n" | Out-String
} else { "sw.js НЕ найден на диске" }

Write-Output ""
Write-Output "=== 2) принудительный бамп кэша: добавляю УНИКАЛЬНЫЙ суффикс в первую строку CACHE ==="
if ($sw) {
  $stamp = "goldFinal" + (Get-Date -Format "HHmmss")
  if ($sw -match '(CACHE(_NAME)?\s*=\s*)[''"]([^''"]+)[''"]') {
    $oldcache = $Matches[3]
    $newcache = $oldcache + "-" + $stamp
    $sw = $sw.Replace('"' + $oldcache + '"', '"' + $newcache + '"')
    $sw = $sw.Replace("'" + $oldcache + "'", "'" + $newcache + "'")
    Set-Content $swv $sw -Encoding UTF8
    "bump: " + $oldcache + "  ->  " + $newcache
  } else {
    $sw = $sw.TrimEnd() + "`n" + "const CACHE_NAME = '" + $stamp + "';"
    Set-Content $swv $sw -Encoding UTF8
    "не было CACHE= шаблона — доаписал: CACHE_NAME = " + $stamp
  }
  $sw2 = Get-Content $swv -Raw -Encoding UTF8
  "новый маркер на диске: " + $sw2.Contains($stamp) + " | байт: " + $sw2.Length
}

Write-Output ""
Write-Output "=== 3) git add + commit + push (ретраи до 7) ==="
Set-Location $repo
git add -A 2>&1 | Out-Null
git commit -m "sw: bump cache -> принудительное обновление у всех посетителей (доставка золотого дизайна)" 2>&1 | Out-String
$local = (& git rev-parse HEAD 2>$null)
$ok = $false
for ($i=1; $i -le 7; $i++) {
  $o = (& git push origin master 2>&1 | Out-String)
  $remote = (& git rev-parse origin/master 2>$null)
  if ($remote -eq $local) { Write-Output ("PUSH OK (попытка " + $i + ") remote=" + $remote); $ok=$true; break }
  Write-Output ("сеть: попытка " + $i + ", ждём 25с"); Start-Sleep 25
}
if(-not $ok){ Write-Output "PUSH FAIL после 7 попыток" }
