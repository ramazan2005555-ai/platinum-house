$ErrorActionPreference = "Stop"
$env.Path = $env.Path + ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$cssg = "C:\872C~1\PLATIN~1\css\style.css"

# ==================== READ CSS FROM GIT HEAD (proven reliable) ====================
$Base64Git = (& git -C $repo show HEAD:css/style.css 2>$null) -join "`n"
"HEAD css bytes = " + $Base64Git.Length
"HEAD has .hero-title = " + $Base64Git.Contains(".hero-title {")
"HEAD already gold-hero = " + $Base64Git.Contains("heroGoldGlow")

# ============ INJECT GOLD HERO (pure ASCII, no regex, deterministic Replace) ============
$AnchorOld = ".hero-title {"
if ($Base64Git.Contains("heroGoldGlow")) {
  "skip: gold hero already in HEAD"
} else {
  $HeroBlock = @"
.hero-title {
  font-family: var(--font-serif);
  font-size: clamp(2.8rem, 6vw, 5rem);
  font-weight: 600;
  line-height: 1.1;
  letter-spacing: 3px;
  text-align: center;
  background: linear-gradient(135deg, #e4c96a 0%, #f8edc0 40%, #c9a84c 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  color: #e4c96a;
  text-shadow: 0 6px 55px rgba(201,168,76,0.4);
  animation: heroGoldGlow 3.2s ease-in-out infinite alternate;
}
@keyframes heroGoldGlow {
  from { text-shadow: 0 6px 40px rgba(201,168,76,0.3); }
  to   { text-shadow: 0 6px 70px rgba(201,168,76,0.6); }
}
"@
  if ($Base64Git.Contains($AnchorOld)) {
    $Base64Git = $Base64Git.Replace($AnchorOld, $HeroBlock)
    "inject OK: .hero-title -> gold hero block"
  } else {
    $Base64Git = $Base64Git.TrimEnd() + "`r`n`r`n" + $HeroBlock
    "inject OK: not found -> appended hero gold block at tail"
  }
}

# ==================== commit the css change ====================
$utf8 = New-Object System.Text.UTF8Encoding($false)
# stage css
Set-Content -LiteralPath $cssg -Value $Base64Git -Encoding UTF8
"css on disk = " + (Get-Item -LiteralPath $cssg).Length
& git -C $repo add "css/style.css" 2>&1 | Out-Null
& git -C $repo commit -m "Gold HERO title (glow+gold gradient) - luxury final" 2>&1 | Out-String
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "Design gold hero done" 2>&1 | Out-Null

# ==================== SW bump for force refresh ====================
$swv = $null
$sw = & git -C $repo show HEAD:sw.js 2>$null | Out-String
if ($sw) {
  ($sw -split "`n" | Select-String "CACHE|VERSION" | Select-Object -First 6) | Out-String
  $m = [regex]::Match($sw, "(?im)^\s*(?:const\s+|var\s+)?(['""]?[A-Za-z0-9_]*CACHE[A-Za-z0-9_]*['""]?\s*=\s*['""])([^'""]+)(['""])")
  if ($m.Success) {
    $old = $m.Groups[2].Value
    $new = $old + "-hero"
    $sw = $sw.Replace("'" + $old + "'", "'" + $new + "'")
    $sw = $sw.Replace('"' + $old + '"', '"' + $new + '"')
    Set-Content -LiteralPath (Join-Path $repo "sw.js") -Value $sw -Encoding UTF8
    "sw bump: " + $old + " -> " + $new
  } else {
    "sw: bump pattern not found, appending marker"
    $sw = $sw.TrimEnd() + "`r`nconst HERO_GOLD = '" + (Get-Date -UFormat %s) + "';`r`n"
    Set-Content -LiteralPath (Join-Path $repo "sw.js") -Value $sw -Encoding UTF8
  }
}

# ==================== PUSH with retries (short ASCII path, works) ====================
& git -C $repo add -A 2>&1 | Out-Null
$local = (& git -C $repo rev-parse HEAD 2>$null)
"local = " + $local
$ok = $false
for ($i = 1; $i -le 9; $i++) {
  & git -C $repo push origin master 2>&1 | Out-Null
  $rm = (& git -C $repo rev-parse origin/master 2>$null)
  if ($rm -eq $local) { "PUSH OK (try " + $i + ")"; $ok = $true; break }
  "net: try " + $i + " remote=" + $rm + " sleep 22"; Start-Sleep 22
}
if (-not $ok) { "PUSH FAIL after 9" }

Start-Sleep 50
Write-Output ""
Write-Output "=== LIVE FINAL CHECK ==="
$base = "https://ramazan2005555-ai.github.io/platinum-house"
$live = (curl.exe -sS --connect-timeout 25 "$base/css/style.css" 2>$null) -join "`n"
"LIVE css bytes        = " + $live.Length
"LIVE gold hero-title  = " + $live.Contains("linear-gradient(135deg, #e4c96a")
"LIVE gold hero-glow   = " + $live.Contains("heroGoldGlow")
"LIVE gold navbar      = " + ($live -match "rgba\(201,168,76,0\.25\)")
"LIVE gold gallery     = " + ($live -match "rgba\(201,168,76,0\.28\)")
"LIVE gold footer      = " + ($live -match "rgba\(201,168,76,0\.18\)")
"LIVE contain (cover=0) = " + $live.Contains("object-fit: contain") + " / " + ([regex]::Matches($live,"object-fit:\s*cover")).Count
$h = (curl.exe -sS --connect-timeout 25 "$base/" 2>$null) -join "`n"
"og:url = " + ([regex]::Match($h,'(?i)og:url" content="([^"]+)"')).Groups[1].Value
foreach($n in "main-menu.jpeg","breakfasts.jpeg","mangal.jpeg","bar-card.jpeg"){
  $c = curl.exe -sS -o NUL -w "%{http_code}" --connect-timeout 20 "$base/img/menu/$n" 2>$null
  "  " + $n + " = " + $c
}