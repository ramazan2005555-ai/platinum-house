$ErrorActionPreference = "Continue"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$cssP = "C:\872C~1\PLATIN~1\css\style.css"
$swP  = "C:\872C~1\PLATIN~1\sw.js"

Write-Output "=== 1) css на диске ==="
$css = $null
if (Test-Path -LiteralPath $cssP) { $css = Get-Content -LiteralPath $cssP -Raw -Encoding UTF8 }
"disk css bytes = " + $css.Length
"disk hero-title = " + $css.Contains(".hero-title {")

Write-Output ""
Write-Output "=== 2) APPEND золотого hero-блока В КОНЕЦ css (каскад: последний выигрывает) ==="
$tail = [Environment]::NewLine + [Environment]::NewLine + @"
/* GOLD HERO - FINAL LUXE (cascade tail) */
.hero-title {
  font-family: var(--font-serif);
  font-weight: 600;
  font-size: clamp(2.8rem, 6vw, 5rem);
  line-height: 1.1;
  letter-spacing: 2px;
  text-align: center;
  background: linear-gradient(135deg, #e4c96a 0%, #f8edc0 40%, #c9a84c 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  color: #e9d183;
  text-shadow: 0 6px 60px rgba(201,168,76,0.35);
  animation: heroGoldGlow 3s ease-in-out infinite alternate;
}
@keyframes heroGoldGlow {
  from { text-shadow: 0 6px 40px rgba(201,168,76,0.30); }
  to   { text-shadow: 0 6px 70px rgba(228,201,106,0.55); }
}
.hero-subtitle {
  letter-spacing: 5px;
  font-weight: 400;
  color: #f3e2ae;
}
.hero-divider {
  width: 110px;
  height: 1px;
  background: linear-gradient(90deg, transparent, #e4c96a, transparent);
  box-shadow: 0 0 18px rgba(228,201,106,0.6);
  margin: 8px auto 26px;
}
"@
$tail = $tail.TrimEnd()
$css2 = $css.TrimEnd() + [Environment]::NewLine + $tail + [Environment]::NewLine
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($cssP, $css2, $utf8)
"после append: диск css bytes = " + (Get-Item -LiteralPath $cssP).Length
"ок"

Write-Output ""
Write-Output "=== 3) бамп sw.js (свежая версия -> форс обновления у телефонов) ==="
$sw = $null
if (Test-Path -LiteralPath $swP) { $sw = Get-Content -LiteralPath $swP -Raw -Encoding UTF8 }
if ($sw -and $sw.Contains("const")) {
  $m = [regex]::Match($sw, "(?im)((?:const\s+)?[A-Z_]*(?:CACHE|VERSION)[A-Z_]*\s*=\s*)['""]([^'""]+)['""]")
  if ($m.Success) {
    $old = $m.Groups[2].Value
    $new = $old + "-hero"
    $sw = $sw.Replace("'" + $old + "'", "'" + $new + "'").Replace('"' + $old + '"', '"' + $new + '"')
    [System.IO.File]::WriteAllText($swP, $sw, $utf8)
    "sw: " + $old + " -> " + $new
  } else {
    [System.IO.File]::AppendAllText($swP, [Environment]::NewLine + "const HERO_GOLD = '" + (Get-Date -UFormat %s) + "';", $utf8)
    "sw: добавил маркер HERO_GOLD (без версии)"
  }
} else {
  "sw на диске нет - пропуск"
}

Write-Output ""
Write-Output "=== 4) git add+commit+push (ретраи до 9) ==="
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "Gold HERO: сияющий золотой заголовок + подсветка подзаголовка/разделителя, sw bump" 2>&1 | Out-String
$local = (& git -C $repo rev-parse HEAD 2>$null)
$ok = $false
for ($i = 1; $i -le 9; $i++) {
  & git -C $repo push origin master 2>&1 | Out-Null
  $rm = (& git -C $repo rev-parse origin/master 2>$null)
  if ($rm -eq $local) { "PUSH OK (try " + $i + ")"; $ok = $true; break }
  "сеть: try " + $i + " rm=" + $rm + " спим 22с"; Start-Sleep 22
}
if (-not $ok) { "PUSH FAIL после 9" }

Write-Output ""
Write-Output "=== 5) ждём Pages (55с) и сверяем ЗОЛОТО ЖИВЬЁМ ==="
Start-Sleep 55
$base = "https://ramazan2005555-ai.github.io/platinum-house"
$live = (curl.exe -sS --connect-timeout 25 "$base/css/style.css" 2>$null) -join "`n"
"LIVE css bytes          = " + $live.Length
"LIVE gold hero-title    = " + $live.Contains("linear-gradient(135deg, #e4c96a")
"LIVE gold hero-sub      = " + $live.Contains("color: #f3e2ae")
"LIVE gold divider       = " + $live.Contains("linear-gradient(90deg, transparent, #e4c96a, transparent)")
"LIVE gold number        = " + $live.Contains("color: #e4c96a")
"LIVE gold navbar        = " + ($live -match "rgba\(201,168,76,0\.25\)")
"LIVE gold gallery       = " + ($live -match "rgba\(201,168,76,0\.28\)")
"LIVE gold lightbox      = " + ($live -match "rgba\(201,168,76,0\.2")
"LIVE gold footer        = " + ($live -match "rgba\(201,168,76,0\.18\)")
"LIVE contain (cover=0)  = " + $live.Contains("object-fit: contain") + " / " + ([regex]::Matches($live,"object-fit:\s*cover")).Count
Write-Output ""
"=== 6) QR: og:url и 4 фото ==="
$h = (curl.exe -sS --connect-timeout 25 "$base/" 2>$null) -join "`n"
"og:url = " + ([regex]::Match($h,'(?i)og:url" content="([^"]+)"')).Groups[1].Value
foreach($n in "main-menu.jpeg","breakfasts.jpeg","mangal.jpeg","bar-card.jpeg"){
  $c = curl.exe -sS -o NUL -w "%{http_code}" --connect-timeout 20 "$base/img/menu/$n" 2>$null
  "  " + $n + " = " + $c
}