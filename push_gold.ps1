$ErrorActionPreference = "Stop"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"

Write-Output "=== git: локальный HEAD vs origin/master (что недоехало) ==="
$local  = (& git -C $repo rev-parse HEAD 2>$null)
$remote = (& git -C $repo rev-parse origin/master 2>$null)
"local  = {0}" -f $local
"remote = {0}" -f $remote
"совпадают = {0}" -f ($local -eq $remote)

if ($local -ne $remote) {
  Write-Output ""
  Write-Output "=== PUSH золотого коммита (до 9 попыток, пауза 25с между) ==="
  $done = $false
  for ($i = 1; $i -le 9; $i++) {
    $o = & git -C $repo push origin master 2>&1 | Out-String
    $r = (& git -C $repo rev-parse origin/master 2>$null)
    if ($r -eq $local) { Write-Output ("PUSH OK на попытке " + $i); $done = $true; break }
    Write-Output ("попытка " + $i + ": сети нет (remote=" + $r + "), жду 25с")
    Start-Sleep 25
  }
  if (-not $done) { Write-Output "PUSH FAIL после 9 попыток" }
} else {
  Write-Output "(уже синхронизировано, push не нужен)"
}

Write-Output ""
Write-Output "=== ждём пересборку Pages (~40с) и проверяем ЖИВОЕ золото ==="
Start-Sleep 40
$base = "https://ramazan2005555-ai.github.io/platinum-house"
$live = (curl.exe -sS --connect-timeout 25 "$base/css/style.css" 2>$null) -join "`n"
"LIVE gold hero-title = " + $live.Contains("linear-gradient(135deg, #e4c96a")
"LIVE gold navbar     = " + $live.Contains("rgba(201,168,76,0.22)")
"LIVE gold gallery    = " + ($live -match "rgba\(201,168,76,0\.28\)")
"LIVE gold number     = " + $live.Contains("color: #e4c96a")
"LIVE gold footer     = " + $live.Contains("rgba(201,168,76,0.18)")
"LIVE gold lightbox   = " + $live.Contains("blur(14px)")
"LIVE object-fit cont = " + $live.Contains("object-fit: contain")
Write-Output ""
Write-Output "=== LIVE: QR-адрес + 4 фото ==="
$h = (curl.exe -sS --connect-timeout 25 "$base/" 2>$null) -join "`n"
"og:url = " + ([regex]::Match($h,'og:url" content="([^"]+)"')).Groups[1].Value
foreach ($n in "main-menu.jpeg","breakfasts.jpeg","mangal.jpeg","bar-card.jpeg") {
  $c = curl.exe -sS -o NUL -w "%{http_code}" --connect-timeout 20 "$base/img/menu/$n" 2>$null
  "  $n => $c"
}
