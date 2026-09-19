$ErrorActionPreference = "Continue"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$cssS = "C:\872C~1\PLATIN~1\css\style.css"
$swS  = "C:\872C~1\PLATIN~1\sw.js"
$repohome = "C:\АРАГ\platinum-house-master"

Write-Output "=== 1) читаю css как BYTES->UTF8 (без Get-Content, без парсера-кодировки) ==="
$css = ""
if (Test-Path -LiteralPath $cssS) {
  try { $css = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($cssS)) } catch {}
}
if (-not $css) { $css = ((& git -C $repo show HEAD:css/style.css 2>$null) -join "`n") }
if (-not $css) { throw "css empty" }
"css bytes = " + $css.Length
"has .hero-title = " + $css.Contains(".hero-title {")
"already GOLD7  = " + $css.Contains("GOLD7LUX")

# ==== 2) если ещё не было — вставляем золотой hero-title блок СРАЗУ после якоря ====
if ($css.Contains(".hero-title {") -and -not $css.Contains("GOLD7LUX")) {
  $gold = @'
GOLD7LUX
@'
  $css = $css.Replace(".hero-title {", @'.hero-title {
  font-family: var(--font-serif);
  font-size: clamp(2.8rem, 6vw, 5rem);
  font-weight: 600;
  line-height: 1.1;
  letter-spacing: 4px;
  text-align: center;
  background: linear-gradient(135deg, #e4c96a 0%, #f8eec0 42%, #c9a84c 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  color: #e4c96a;
  text-shadow: 0 6px 70px rgba(201,168,76,0.45);
  animation: heroGoldPulse 3.2s ease-in-out infinite alternate;
}
@keyframes heroGoldPulse {
  from { text-shadow: 0 6px 45px rgba(201,168,76,0.30); }
  to   { text-shadow: 0 6px 90px rgba(228,201,106,0.60); }
}
.hero-subtitle {
  letter-spacing: 5px;
  font-weight: 400;
}
.hero-divider {
  width: 130px;
  height: 1px;
  background: linear-gradient(90deg, transparent, #e4c96a, transparent);
  box-shadow: 0 0 22px rgba(201,168,76,0.7);
}
.gallery-number {
  color: var(--gold);
  font-family: var(--font-serif);
  letter-spacing: 3px;
}
.gallery-label {
  font-family: var(--font-serif);
  letter-spacing: 0.15em;
  color: #f3e2ae;
}
.navbar {
  border-bottom: 1px solid rgba(201,168,76,0.35);
  background: rgba(7,7,7,0.8);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}
.nav-links a {
  color: #fff2cc;
  letter-spacing: 0.16em;
  text-transform: uppercase;
}
.footer {
  border-top: 1px solid rgba(201,168,76,0.18);
}
.footer a {
  color: #e9d183;
}
.gallery-img,
.gallery-img-wrapper img,
.lightbox-img {
  object-fit: contain;
}
.lightbox {
  background: rgba(4,4,4,0.95);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}
'@)
  "gold inserted into css"
} else {
  "gold already present (GOLD7LUX) OR anchor missing"
}

# ===== 3) сохраняем на ДИСК через writebytes UTF8(noBOM) =====
$utf8B = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllBytes($cssS, $utf8B.GetBytes($css))
"disk css bytes = " + (Get-Item -LiteralPath $cssS).Length
$diskChk = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($cssS))
"DISK hero-title gold = " + $diskChk.Contains("linear-gradient(135deg, #e4c96a")
"DISK contain (cover0) = " + $diskChk.Contains("object-fit: contain") + " / " + ([regex]::Matches($diskChk,"object-fit:\s*cover")).Count

# ===== 4) sw bump (читаем как bytes->UTF8, аппендим ASCII-маркер) =====
if (Test-Path -LiteralPath $swS) {
  $sw = ""
  try { $sw = [System.Text.Encoding]::UTF8.GetString([System.IO.File]::ReadAllBytes($swS)) } catch {}
  if ($sw) {
    $sw = $sw.TrimEnd() + "`n" + "const SWGOLD7 = '" + (Get-Date -UFormat "%s") + "';`n"
    [System.IO.File]::WriteAllBytes($swS, $utf8B.GetBytes($sw))
    "sw bumped, bytes = " + (Get-Item -LiteralPath $swS).Length
  }
} else { "sw.js missing on short path — пропуск" }

# ===== 5) git add/commit/push (ретраи 9x через короткий путь) =====
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "GOLDHERO7 LUXE: gold gradient hero-title, glow divider, gold navbar/footer/gallery numbers, unreal contain, sw7" 2>&1 | Out-Null
$local = (& git -C $repo rev-parse HEAD 2>$null)
$pushed = $false
for ($i = 1; $i -le 9; $i++) {
  & git -C $repo push origin master 2>&1 | Out-Null
  $rm = (& git -C $repo rev-parse origin/master 2>$null)
  if ($rm -eq $local) { "PUSH OK (try " + $i + ")"; $pushed = $true; break }
  "net try " + $i + ": remote=" + $rm + " ждём 24с"; Start-Sleep 24
}
if (-not $pushed) { "PUSH FAIL" }

Write-Output ""
Write-Output "=== 6) ждём Pages пересборку 55с и проверяем ЖИВОЙ css ==="
Start-Sleep 60
$base = "https://ramazan2005555-ai.github.io/platinum-house"
$live = (curl.exe -sS --connect-timeout 25 "$base/css/style.css" 2>$null) -join "`n"
"LIVE css bytes        = " + $live.Length
"LIVE gold hero-title  = " + $live.Contains("linear-gradient(135deg, #e4c96a")
"LIVE gold hero-pulse  = " + $live.Contains("heroGoldPulse")
"LIVE gold navbar      = " + ($live -match "rgba\(201,168,76,0\.35\)")
"LIVE gold gallery     = " + ($live -match "rgba\(201,168,76,0\.18\)")
"LIVE gold number      = " + $live.Contains("color: var(--gold)")
"LIVE gold label       = " + $live.Contains("color: #f3e2ae")
"LIVE gold lightbox    = " + $live.Contains("blur(12px)")
"LIVE contain (no cover) = " + $live.Contains("object-fit: contain") + " / cover-" + ([regex]::Matches($live,"object-fit:\s*cover")).Count
$h = (curl.exe -sS --connect-timeout 25 "$base/" 2>$null) -join "`n"
"og:url = " + ([regex]::Match($h,'(?i)og:url" content="([^"]+)"')).Groups[1].Value
foreach($n in "main-menu.jpeg","breakfasts.jpeg","mangal.jpeg","bar-card.jpeg"){
  $c = curl.exe -sS -o NUL -w "%{http_code}" --connect-timeout 20 "$base/img/menu/$n" 2>$null
  "  " + $n + " => " + $c
}