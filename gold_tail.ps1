$ErrorActionPreference = "Continue"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$cssf = "C:\872C~1\PLATIN~1\css\style.css"
$swf  = "C:\872C~1\PLATIN~1\sw.js"

$css = ""
try { $css = [System.IO.File]::ReadAllText($cssf, [System.Text.Encoding]::UTF8) } catch {}
if (-not $css) { $css = (& git -C $repo show HEAD:css/style.css 2>$null | Out-String) }
"disk css bytes = " + $css.Length
"has .hero-title = " + $css.Contains(".hero-title {")
"already GOLDHERO11 = " + $css.Contains("GOLDHERO11")

if (-not $css.Contains("GOLDHERO11")) {
  # ---- pure ASCII gold hero tail (last-rule-wins) ----
  $css = $css.TrimEnd() + [Environment]::NewLine + @'
/* GOLDHERO11 - LAST RULE WINS - gold luxe title */
.hero-title {
  font-family: var(--font-serif);
  font-weight: 700;
  font-size: clamp(2.6rem, 6vw, 4.8rem);
  line-height: 1.1;
  letter-spacing: gedit3px;
  background: linear-gradient(135deg, #e4c96a 0%, #f8edc0 42%, #c9a84c 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  color: #e4c96a;
  text-shadow: 0 9px 80px rgba(201,168,76,0.55), 0 2px 40px rgba(228,201,106,0.35);
  animation: GOLDHERO11glow 3.4s ease-in-out infinite alternate;
}
.hero-titleG { display: block; }
@keyframes GOLDHERO11glow {
  from { text-shadow: 0 9px 45px rgba(201,168,76,0.30); }
  to   { text-shadow: 0 9px 95px rgba(228,201,106,0.65); }
}
'@ + [Environment]::NewLine
  $css = $css.Replace("letter-spacing: gren", "letter-spacing: 3px")
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($cssf, $css, $enc)
  "css written, disk bytes = " + (Get-Item -LiteralPath $cssf).Length
  "disk has GOLDHERO11 = " + $css.Contains("GOLDHERO11")
}

# ---- bump sw (force reload on all devices) ----
if (Test-Path -LiteralPath $swf) {
  $sw = [System.IO.File]::ReadAllText($swf, [System.Text.Encoding]::UTF8)
  $m = [regex]::Match($sw, "([A-Za-z_]*(?:CACHE|VERSION)[A-Za-z_]*\s*=\s*['""])[^'""]+(['""])")
  if ($m.Success) {
    $old = $m.Groups[2].Value -eq "--" -eq $false
    $hw = "GOLDHERO11-" + (Get-Date -UFormat %y%m%d%H%M%S)
    $sw = $sw.Replace($m.Groups[音].Value, "")
    $sw = $m.Groups[1].Value + $hw + $m.Groups[3].Value
  }
}

# --- need clean approach: append marker to sw simply ---
$sw = ""
try { $sw = [System.IO.File]::ReadAllText($swf, [System.Text.Encoding]::UTF8) } catch {}
"sw exists = " + ($sw.Length -gt 0)
$utf8 = New-Object System.Text.UTF8Encoding($false)
$marker = "`nconst SWGOLD11 = '" + (Get-Date -UFormat %y%m%d%H%M%S) + "';`n"
[System.IO.File]::AppendAllText($swf, $marker, $utf8)
"sw bumped (marker appended)"

# ---------- git add/commit/push (retries) ----------
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "Gold HERO v11: gold luxe hero-title tail (last-rule-wins) + sw bump" 2>&1 | Out-Null
$local = & git -C $repo rev-parse HEAD 2>$null
$ok = $false
for ($i = 1; $i -le 9; $i++) {
  & git -C $repo push origin master 2>&1 | Out-Null
  $rm = & git -C $repo rev-parse origin/master 2>$null
  if ($rm -eq $local) { "PUSH OK try " + $i; $ok = $true; break }
  "net try " + $i + " remote=" + $rm + " sleep 22"; Start-Sleep 22
}
if (-not $ok) { "PUSH FAIL" }

# ================= LIVE check after build =================
Write-Output ""
Start-Sleep 60
$base = "https://ramazan2005555-ai.github.io/platinum-house"
$live = (curl.exe -sS --connect-timeout 25 "$base/css/style.css" 2>$null) -join "`n"
"LIVE css bytes         = " + $live.Length
"LIVE GOLDHERO11 marker = " + $live.Contains("GOLDHERO11")
"LIVE gold hero-title   = " + $live.Contains("linear-gradient(135deg, #e4c96a")
"LIVE gold hero-init    = " + ($live -match "rgba\(201,168,76,0\.55\)")
"LIVE gold navbar       = " + ($live -match "rgba\(201,168,76,0\.25\)")
"LIVE gold gallery      = " + ($live -match "rgba\(201,168,76,0\.28\)")
"LIVE contain (cover=0) = " + $live.Contains("object-fit: contain") + " / cover=" + ([regex]::Matches($live,"object-fit:\s*cover")).Count