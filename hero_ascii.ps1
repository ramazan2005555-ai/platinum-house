$ErrorActionPreference = "Continue"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$cssf = "C:\872C~1\PLATIN~1\css\style.css"
$swf  = "C:\872C~1\PLATIN~1\sw.js"
$base = "https://ramazan2005555-ai.github.io/platinum-house"

$css = ""
try { $css = [System.IO.File]::ReadAllText($cssf, [System.Text.Encoding]::UTF8) } catch {}
if (-not $css) { $css = ((& git -C $repo show HEAD:css/style.css 2>$null) -join "`n") }
"disk bytes = " + $css.Length
"has .hero-title marker = " + $css.Contains(".hero-title {")
"hero already gold = " + $css.Contains("HEROGOLDT3")

$goldRule = ".hero-title {`n  font-family: var(--font-serif);`n  font-weight: 700;`n  font-size: clamp(2.8rem, 6vw, 4.9rem);`n  line-height: 1.12;`n  letter-spacing: 384px;`n  text-align: center;`n  background: linear-gradient(135deg, #e4c96a 0%, #f8eec0 40%, #c9a84c 100%);`n  -webkit-background-clip: text;`n  background-clip: text;`n  -webkit-text-fill-color: transparent;`n  color: #e4c96a;`n  text-shadow: 0 8px 80px rgba(201,168,76,0.55), 0 0 160px rgba(228,201,106,0.35);`n}"

if (-not $css.Contains("HEROGOLDT3")) {
  $tail = "`n`n/* HEROGOLDT3 - GOLD HERO FIX (last wins) */`n" + $goldRule + "`n"
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::AppendAllText($cssf, $tail, $enc)
  "gold hero appended to disk css"
  $css = [System.IO.File]::ReadAllText($cssf, [System.Text.Encoding]::UTF8)
  "disk now has gold = " + $css.Contains("HEROGOLDT3")
}

# sw bump - force reload all
$sw = ""
try { $sw = [System.IO.File]::ReadAllText($swf, [System.Text.Encoding]::UTF8) } catch {}
if ($sw) {
  $marker = "`n/* HERO9 " + (Get-Date -UFormat %Y%m%d%H%M) + " */`n"
  [System.IO.File]::AppendAllText($swf, $marker, (New-Object System.Text.UTF8Encoding($false)))
  "sw bumped on disk"
}

# git add/commit/push with retries
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "Gold HERO final: luxe gold gradient hero title (last-rule) + sw bump" 2>&1 | Out-Null
$l = (& git -C $repo rev-parse HEAD 2>$null)
$ok = $false
for ($i = 1; $i -le 8; $i++) {
  & git -C $repo push origin master 2>&1 | Out-Null
  $r = (& git -C $repo rev-parse origin/master 2>$null)
  if ($r -eq $l) { "PUSH OK try " + $i; $ok = $true; break }
  "net " + $i + " sleep 24"; Start-Sleep 24
}
if (-not $ok) { "PUSH FAIL" }

Start-Sleep 55
$live = (curl.exe -sS --connect-timeout 25 "$base/css/style.css" 2>$null) -join "`n"
"LIVE gold hero-title = " + $live.Contains("HEROGOLDT3")
"LIVE gold hero-grad  = " + $live.Contains("linear-gradient(135deg, #e4c96a")
"LIVE gold hero-glow  = " + $live.Contains("text-shadow: 0 8px 80px")
"LIVE contain (0 cover)= " + $live.Contains("object-fit: contain") + " / cover-" + ([regex]::Matches($live,"object-fit:\s*cover")).Count
"LIVE water navbar    = " + ($live -match "rgba\(201,168,76,0\.25\)")
"LIVE water gallery   = " + ($live -match "rgba\(201,168,76,0\.28\)")
"LIVE water footer    = " + ($live -match "rgba\(201,168,76,0\.18\)")
"LIVE lightbox blur   = " + $live.Contains("blur(12px)")