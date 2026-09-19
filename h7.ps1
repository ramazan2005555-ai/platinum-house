$ErrorActionPreference = "Stop"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$cssp = "C:\872C~1\PLATIN~1\css\style.css"
$swp  = "C:\872C~1\PLATIN~1\sw.js"

# ===== 1) читаем css с ДИСКА (надёжно, без git) =====
$css = ""
if (Test-Path -LiteralPath $cssp) { $css = Get-Content -LiteralPath $cssp -Raw -Encoding UTF8 }
if (-not $css) { throw "css no on disk" }
"css disk bytes = " + $css.Length
"contains .hero-title = " + $css.Contains(".hero-title {")

# ===== 2) золото: переопределить .hero-title через каскад (правило в конец css) =====
$block = ".hero-title {"
$block = $block + " background: linear-gradient(135deg, #e4c96a 0%, #f7e8b0 45%, #c9a84c 100%);"
$block = $block + " -webkit-background-clip: text; background-clip: text;"
$block = $block + " -webkit-text-fill-color: transparent;"
$block = $block + " font-family: var(--font-serif);"
$block = $block + " font-weight: 600;"
$block = $block + " font-size: clamp(2.6rem, 6vw, 4.6rem);"
$block = $block + " line-height: 1.12;"
$block = $block + " letter-spacing: 2px;"
$block = $block + " text-shadow: 0 6px 60px rgba(201,168,76,0.45);"
$block = $block + " margin: 0 auto 18px;"
$block = $block + " }"

$block = [Environment]::NewLine + "/* gold-force */" + [Environment]::NewLine + $block + [Environment]::NewLine

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::AppendAllText($cssp, $block, $enc)
"appended. disk bytes = " + (Get-Item -LiteralPath $cssp).Length

# ===== 3) bump служсер-воркера чтобы все телефоны получили свежий css =====
if (Test-Path -LiteralPath $swp) {
  $sw = Get-Content -LiteralPath $swp -Raw -Encoding UTF8
  $m = [regex]::Match($sw, "(?m)^\s*const\s+([A-Z_]+)\s*=\s*['""]([A-Za-z0-9_.\-]+)['""]")
  if ($m.Success) {
    $vari = $m.Groups[2].Value
    $sw2 = $sw.Replace("'" + $vari + "'", "'" + $vari + "-gold6'")
    Set-Content -LiteralPath $swp $sw2 -Encoding UTF8
    "sw bumped: " + $vari + " -> " + $vari + "-gold6"
  } else {
    "sw: version const not found, appending marker"
    Add-Content -LiteralPath $swp ("`nconst SWGOLDV = '" + (Get-Date -UFormat "%s") + "';") -Encoding UTF8
  }
}

# ===== 4) git add + commit + push (короткий ASCII путь, ретраи) =====
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "hero-title GOLD - cascade override at css tail; sw bump gold6" 2>&1 | Out-Null
$local = (& git -C $repo rev-parse HEAD 2>$null)
$ok = $false
for ($i = 1; $i -le 9; $i++) {
  & git -C $repo push origin master 2>&1 | Out-Null
  $rm = (& git -C $repo rev-parse origin/master 2>$null)
  if ($rm -eq $local) { "PUSH OK try " + $i; $ok = $true; break }
  "net try " + $i + ", remote=" + $rm + " ; sleep 22s"
  Start-Sleep 22
}
if (-not $ok) { "PUSH FAIL" }

Write-Output ""
Write-Output "=== ждем Pages rebuild 40s ==="
Start-Sleep 40
$base = "https://ramazan2005555-ai.github.io/platinum-house"
$live = (curl.exe -sS --connect-timeout 25 "$base/css/style.css" 2>$null) -join "`n"
"LIVE css bytes  = " + $live.Length
"LIVE hero gold  = " + $live.Contains("linear-gradient(135deg, #e4c96a")
"LIVE clamp gold = " + $live.Contains("clamp(2.6rem, 6vw, 4.6rem)")
"LIVE gold-force = " + $live.Contains("gold-force")
"LIVE contain    = " + $live.Contains("object-fit: contain")
"LIVE cover left = " + ([regex]::Matches($live,"object-fit:\s*cover")).Count
Write-Output ""
"=== QR/og:url (не менялся) ==="
$h = (curl.exe -sS --connect-timeout 25 "$base/" 2>$null) -join "`n"
$u = ([regex]::Match($h,'(?i)og:url" content="([^"]+)"')).Groups[1].Value
"og:url = " + $u
"=== 4 фото ==="
foreach ($n in "main-menu.jpeg","breakfasts.jpeg","mangal.jpeg","bar-card.jpeg") {
  $c = curl.exe -sS -o NUL -w "%{http_code}" --connect-timeout 20 "$base/img/menu/$n" 2>$null
  "  " + $n + " => " + $c
}