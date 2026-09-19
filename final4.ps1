$ErrorActionPreference = "Stop"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$cssv = "C:\872C~1\PLATIN~1\css\style.css"
$swPath = "C:\872C~1\PLATIN~1\sw.js"

# ============ 1) золото hero-title (на диске, UTF8-safe) ============
$css = $null
if (Test-Path -LiteralPath $cssv) { $css = Get-Content $cssv -Raw -Encoding UTF8 }
if ($css) {
  "css на диске байт = " + $css.Length
  $needle = ".hero-title {"
  if ($css.Contains($needle) -and -not $css.Contains("linear-gradient(135deg, #e4c96a")) {
    $css = $css.Replace($needle, @"
.hero-title {
  font-size: clamp(2.6rem, 6vw, 4.8rem);
  line-height: 1.12;
  letter-spacing: 2px;
  background: linear-gradient(135deg, #e4c96a 0%, #f7e8b0 42%, #c9a84c 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  text-shadow: 0 6px 60px rgba(201,168,76,0.35);
"@)
    Set-Content $cssv $css -Encoding UTF8
    "hero-title: золото применено"
  } else {
    "hero-title: уже золото на диске  ИЛИ якорь не найден (skip)"
  }
} else { "css на диске не прочитался — это НЕ страшно, правим ниже через git HEAD" }

# ============ 2) bump cache-версии в sw.js на диске ============
$sw = $null
if (Test-Path -LiteralPath $swPath) { $sw = Get-Content $swPath -Raw -Encoding UTF8 }
if (-not $sw) {
  Write-Output "sw.js на диске нет — читаю из git HEAD (ХОТЯ это значит sw добавится заново?)"
  $hh = (& git -C $repo show "HEAD:sw.js" 2>$null | Out-String)
  if ($hh) { $sw = $hh; Set-Content $swPath $hh -Encoding UTF8; "sw.js восстановлен из HEAD на диск" }
}
if ($sw) {
  if ($sw -match '([A-Z_]*CACHE(_NAME)?\s*=\s*)[''"]([^''"]+)[''"]') {
    $oldc = $Matches[3]
    $newc = $oldc + "-gold4"
    $sw = $sw.Replace("'$oldc'", "'$newc'")
    $sw = $sw.Replace('"' + $oldc + '"', '"' + $newc + '"')
    Set-Content $swPath $sw -Encoding UTF8
    "sw cache: " + $oldc + "  ->  " + $newc
  }
}

# ============ 3) коммит + push с ретраями ============
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "Design v5: gold hero-title gradient (glow), SW cache bump -> gold4 (force refresh for all visitors)" 2>&1 | Out-String
$local = (& git -C $repo rev-parse HEAD 2>$null)
$ok = $false
for ($i = 1; $i -le 7; $i++) {
  & git -C $repo push origin master 2>&1 | Out-String
  $remote = (& git -C $repo rev-parse origin/master 2>$null)
  if ($remote -eq $local) { Write-Output ("PUSH OK на попытке " + $i); $ok = $true; break }
  Write-Output ("сеть: попытка " + $i + ", remote= " + $remote + " — ждём 25с")
  Start-Sleep 25
}
Write-Output ("всего запушено? " + $ok)

# ============ 4) ждём Pages пересборку (~40с) и проверяем ЖИВОЕ золото ============
Write-Output ""
Write-Output "=== ждём Pages (40с) ==="
Start-Sleep 40
$base = "https://ramazan2005555-ai.github.io/platinum-house"
$livecss = (curl.exe -sS --connect-timeout 25 "$base/css/style.css" 2>$null) -join "`n"
"LIVE gold hero-title = " + $livecss.Contains("linear-gradient(135deg, #e4c96a")
"LIVE gold navbar 0.25 = " + $livecss.Contains("rgba(201,168,76,0.25)")
"LIVE gold gallery 0.28= " + ($livecss -match "rgba\(201,168,76,0\.28\)")
"LIVE gold number      = " + $livecss.Contains("color: #e4c96a")
"LIVE gold footer 0.18 = " + $livecss.Contains("rgba(201,168,76,0.18)")
"LIVE gold lightbox bl = " + $livecss.Contains("blur(12px)")
"LIVE object-fit cont  = " + $livecss.Contains("object-fit: contain")
Write-Output ""
Write-Output "=== LIVE: og:url (QR не трогали) + 4 фото ==="
$h = (curl.exe -sS --connect-timeout 25 "$base/" 2>$null) -join "`n"
"og:url = " + ([regex]::Match($h,'(?i)og:url" content="([^"]+)"')).Groups[1].Value
foreach($n in "main-menu.jpeg","breakfasts.jpeg","mangal.jpeg","bar-card.jpeg"){
  $c = curl.exe -sS -o NUL -w "%{http_code}" --connect-timeout 20 "$base/img/menu/$n" 2>$null
  "  $n => $c"
}