$ErrorActionPreference = "Continue"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$cssShort = "C:\872C~1\PLATIN~1\css\style.css"
$swShort  = "C:\872C~1\PLATIN~1\sw.js"

$css = ""
try { $css = [System.IO.File]::ReadAllText($cssShort, [System.Text.Encoding]::UTF8) } catch { }
if (-not $css) { $css = ((& git -C $repo show HEAD:css/style.css 2>&1) -join "`n") -replace "`r","" }
"css on disk/HEAD bytes = " + $css.Length
"has .hero-title = " + $css.Contains(".hero-title {")

# ---------- 1) GOLD HERO: append override (last rule wins in CSS) ----------
if (-not $css.Contains("GOLD HERO v9")) {
  $tailCss = @"
`n/* GOLD HERO v9 - shimmering platinum gold headline */
.hero-title {
  font-family: var(--font-serif);
  font-size: clamp(2.8rem, 6vw, 4.9rem);
  font-weight: 600;
  line-height: 1.12;
  letter-spacing: 4px;
  text-align: center;
  background: linear-gradient(135deg, #e4c96a 0%, #f8efc8 42%, #cfae54 70%, #ead496 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  color: #e4c96a;
  text-shadow: 0 8px 80px rgba(201,168,76,0.55), 0 0 160px rgba(228,201,106,0.30);
  animation: heroGlowPulse 3.4s ease-in-out infinite alternate;
}
@keyframes heroGlowPulse {
  from { text-shadow: 0 8px 50px rgba(201,168,76,0.35); }
  to   { text-shadow: 0 8px 110px rgba(228,201,106,0.70); }
}
.hero-badge {
  color: #e4c96a;
  letter-spacing: 8px;
  font-weight: 600;
}
.hero-divider {
  width: 130px;
  height: 1px;
  background: linear-gradient(90deg, transparent, #e4c96a, transparent);
  box-shadow: 0 0 24px rgba(228,201,106,0.8), 0 0 60px rgba(228,201,106,0.4);
}
.hero-subtitle {
  color: #f3e8c8;
  letter-spacing: 4px;
}
"@
  $newCss = $css.TrimEnd() + $tailCss + "`n"
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($cssShort, $newCss, $utf8)
  "css wrote, disk bytes = " + (Get-Item -LiteralPath $cssShort).Length
} else {
  "GOLD HERO v9 already present"
}

# ---------- 2) SW bump (force refresh all phones) ----------
$sw = ""
try { $sw = [System.IO.File]::ReadAllText($swShort, [System.Text.Encoding]::UTF8) } catch { }
if ($sw) {
  $m = [regex]::Match($sw, "(?im)([A-Z_]*CACHE[A-Z_]*\s*=\s*['""])[^'""]+(['""])")
  if ($m.Success) {
    $old = $m.Groups[0].Value
    $new = $m.Groups[1].Value + "v9-goldhero" + $m.Groups[2].Value
    $sw = $sw.Replace($old, $new)
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($swShort, $sw, $utf8)
    "sw bumped"
  }
}

# ---------- 3) git add/commit/push with retries ----------
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "Gold HERO v9: shimmering platinum-gold headline + glow keys + SW bump (all visitors reload)" 2>&1 | Out-Null
$l = (& git -C $repo rev-parse HEAD 2>$null)
$ok = $false
for ($i = 1; $i -le 10; $i++) {
  & git -C $repo push origin master 2>&1 | Out-Null
  $r = (& git -C $repo rev-parse origin/master 2>$null)
  if ($r -eq $l) { "PUSH OK try " + $i; $ok = $true; break }
  "net try " + $i + " sleep 25"; Start-Sleep 25
}
if (-not $ok) { "PUSH FAIL" }

# ---------- 4) wait Pages rebuild + LIVE verify ----------
Start-Sleep 55
$base = "https://ramazan2005555-ai.github.io/platinum-house"
$live = (curl.exe -sS --connect-timeout 25 "$base/css/style.css" 2>$null) -join "`n"
"LIVE bytes      = " + $live.Length
"LIVE hero GOLD  = " + $live.Contains("linear-gradient(135deg, #e4c96a")
"LIVE glow key   = " + $live.Contains("heroGlowPulse")
"LIVE navbar gold= " + $live.Contains("rgba(201,168,76,0.25)")
"LIVE footer gold= " + $live.Contains("rgba(201,168,76,0.18)")
"LIVE contain    = " + $live.Contains("object-fit: contain") + " cover=" + ([regex]::Matches($live,"object-fit:\s*cover")).Count
$h = (curl.exe -sS --connect-timeout 25 "$base/" 2>$null) -join "`n"
"og:url = " + ([regex]::Match($h,'(?i)og:url" content="([^"]+)"')).Groups[1].Value