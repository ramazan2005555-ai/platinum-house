$ErrorActionPreference = "Continue"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"

$cssShort = "C:\872C~1\PLATIN~1\css\style.css"
$swShort  = "C:\872C~1\PLATIN~1\sw.js"

# ---------- READ css ----------
$css = ""
if (Test-Path -LiteralPath $cssShort) {
  try { $css = [System.IO.File]::ReadAllText($cssShort, [System.Text.Encoding]::UTF8) } catch { $css = "" }
}
if (-not $css) { $css = ((& git -C $repo show "HEAD:css/style.css" 2>$null) -join "`n") }
"css get bytes = " + $css.Length
"css has .hero-title = " + $css.Contains(".hero-title {")

# ---------- GOLD HERO override (append ASCII-only tail; later CSS wins) ----------
$gold = @"

/* GOLD HERO - platinum luxe (final tail) */
.hero-title {
  font-family: var(--font-serif);
  font-weight: 600;
  font-size: clamp(2.8rem, 6vw, 4.9rem);
  line-height: 1.1;
  letter-spacing: 4px;
  text-align: center;
  background: linear-gradient(135deg, #e4c96a 0%, #f7eec0 45%, #cfae54 70%, #e9d183 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  color: #e9d183;
  text-shadow: 0 8px 70px rgba(228,201,106,0.45);
}
.hero-subtitle {
  color: #f3e6b8;
  font-weight: 400;
  letter-spacing: 4px;
}
.hero-divider {
  width: 130px;
  height: 1px;
  background: linear-gradient(90deg, transparent, #e4c96a, transparent);
  box-shadow: 0 0 22px rgba(228,201,106,0.65);
}
"@

if ($css.Contains("GOLD HERO - platinum luxe")) {
  "already tail-append done (skip)"
} else {
  $tail = $css.TrimEnd() + [Environment]::NewLine + "`n" + $gold + [Environment]::NewLine
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($cssShort, $tail, $utf8)
  "appended, disk css bytes = " + (Get-Item -LiteralPath $cssShort).Length
}

# ---------- SW bump ----------
$sw = ""
if (Test-Path -LiteralPath $swShort) {
  try { $sw = [System.IO.File]::ReadAllText($swShort, [System.Text.Encoding]::UTF8) } catch { $sw = "" }
}
if ($sw) {
  $stamp = (Get-Date -Format "yyyyMMddHHmmss")
  if ($sw -notmatch "HEROGOLD") {
    $sw = $sw.TrimEnd() + "`nconst HEROGOLD = '" + $stamp + "';`n"
  } else {
    $sw = $sw.Replace("HEROGOLD = '", "HEROGOLD = '" + $stamp + "X").Replace("'`n", "'`n")
    $sw = [regex]::Replace($sw, "HEROGOLD = '[^']*'", "HEROGOLD = '" + $stamp + "'")
  }
  [System.IO.File]::WriteAllText($swShort, $sw, (New-Object System.Text.UTF8Encoding($false)))
  "sw bumped, marker = " + $stamp
}

# ---------- git add/commit/push ----------
& git -C $repo add -A 2>$null | Out-Null
& git -C $repo commit -m "GOLD HERO final: luxe gold hero-title + divider glow, sw bump (all visitors refresh)" 2>$null | Out-Null
$local = (& git -C $repo rev-parse HEAD 2>$null)
$ok = $false
for ($i = 1; $i -le 9; $i++) {
  & git -C $repo push origin master 2>$null | Out-Null
  $rm = (& git -C $repo rev-parse origin/master 2>$null)
  if ($rm -eq $local) {
    "PUSH OK try " + $i
    $ok = $true
    break
  }
  "net try " + $i + " remote=" + $rm + " sleep 22s"
  Start-Sleep 22
}
if (-not $ok) { "PUSH FAIL after 9 tries" }
