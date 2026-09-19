$ErrorActionPreference = "Continue"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$cssf = "C:\872C~1\PLATIN~1\css\style.css"
$swf  = "C:\872C~1\PLATIN~1\sw.js"

$css = ""
try { $css = [System.IO.File]::ReadAllText($cssf, [System.Text.Encoding]::UTF8) } catch {}
if (-not $css) { try { $css = (& git -C $repo show HEAD:css/style.css 2>$null) -join "`n" } catch {} }
"disk css bytes = " + $css.Length
"disk .hero-title anchor = " + $css.Contains(".hero-title {")

# ---------- GOLD HERO TAIL (last rule wins in CSS) ----------
$tail = @"
/* GOLDHEROTAIL westgold v12 - final luxe - runs LAST so it always wins */
.navbar {
  background: rgba(5,5,5,0.80) !important;
  border-bottom: 1px solid rgba(201,168,76,0.35) !important;
  box-shadow: 0 4px 40px rgba(0,0,0,0.55), 0 0 1px 1px rgba(201,168,76,0.18) !important;
  backdrop-filter: blur(16px) saturate(1.25) !important;
  -webkit-backdrop-filter: blur(16px) saturate(1.25) !important;
}
.nav-links a,
.nav-link {
  color: #f2e6bc !important;
  letter-spacing: 1.6px;
  text-transform: uppercase;
}
.hero-title,
.hero-title span,
.page-hero-title,
.hero-card-title {
  font-family: var(--font-serif);
  font-weight: 600;
  letter-spacing: 4px;
  font-size: clamp(2.7rem, 6vw, 4.8rem);
  line-height: 1.12;
  text-align: center;
  background: linear-gradient(135deg, #e4c96a 0%, #fbefc6 42%, #cfae54 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  color: #e4c96a;
  text-shadow: 0 6px 70px rgba(201,168,76,0.5);
  animation: goldHeroTail 3.4s ease-in-out infinite alternate;
}
@keyframes goldHeroTail {
  from { text-shadow: 0 5px 45px rgba(201,168,76,0.35); }
  to   { text-shadow: 0 5px 100px rgba(228,201,106,0.72); }
}
.hero-title {
  font-size: clamp(2.9rem, 6.4vw, 5rem) !important;
  text-shadow: 0 9px 90px rgba(201,168,76,0.55) !important;
}
/* thumbnails always full, never cropped */
.gallery-img,
.gallery-img-list img,
.menu-photo,
.photo,
.responsive-img {
  object-fit: contain !important;
}
.hero-divider {
  background: linear-gradient(90deg, transparent, #e4c96a, transparent) !important;
  box-shadow: 0 0 26px rgba(228,201,106,0.8) !important;
}
.hero-badge {
  color: #e4c96a !important;
  letter-spacing: 7px;
}
.footer {
  border-top: 1px solid rgba(201,168,76,0.22) !important;
}
"@

if ($css.Contains("GOLDHEROTAIL westgold v12")) {
  "already tail present - skip"
} else {
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $content = "`n" + $tail + "`n"
  [System.IO.File]::AppendAllText($cssf, $content, $utf8)
  "tail appended; disk css bytes now = " + (Get-Item -LiteralPath $cssf).Length
  $chk = [System.IO.File]::ReadAllText($cssf, [System.Text.Encoding]::UTF8)
  "verify on disk: GOLDHEROTAIL = " + $chk.Contains("GOLDHEROTAIL westgold v12")
  "verify on disk: gold hero    = " + $chk.Contains("linear-gradient(135deg, #e4c96a")
  "verify on disk: contain      = " + $chk.Contains("object-fit: contain !important")
}

# ---------- bump SW cache so all phones refresh ----------
$sw = ""
try { $sw = [System.IO.File]::ReadAllText($swf, [System.Text.Encoding]::UTF8) } catch {}
if ($sw) {
  $bumped = $false
  if ($sw -match "(?im)((?:CACHE|CACHE_NAME|version|VERSION)\s*=\s*[`"'])") {
    # direct ascii replace on a simple anchor if present, else append marker
    $m2 = [regex]::Match($sw, "(?im)(['""][^'""]*gold[^'""]*['""])")
    if ($m2.Success) {
      $old = $m2.Groups[1].Value
      $new = "'goldtail-v" + (Get-Date -UFormat %H%M%S) + "'"
      $sw = $sw.Replace($old, $new)
      "sw: " + $old + " -> " + $new
      $bumped = $true
    }
  }
  if (-not $bumped) {
    $marker = "`n// goldtail " + (Get-Date -UFormat %s) + "`n"
    $sw = $sw.TrimEnd() + $marker
    "sw: appended goldtail marker (key bump)"
  }
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($swf, $sw, $utf8)
  "sw disk bytes = " + (Get-Item -LiteralPath $swf).Length
} else {
  "sw: not found, skip"
}

# ---------- git add/commit/push with retries ----------
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "GOLD TAIL v12: luxe gold hero-title gradient+glow tail (always-wins), gold navbar/footer/divider, contain force, sw bump" 2>&1 | Out-Null
$local = & git -C $repo rev-parse HEAD 2>$null
$ok = $false
for ($i = 1; $i -le 9; $i++) {
  & git -C $repo push origin master 2>&1 | Out-Null
  $rm = & git -C $repo rev-parse origin/master 2>$null
  if ($rm -eq $local) { "PUSH OK try " + $i; $ok = $true; break }
  "net try " + $i + " remote=" + $rm + " ; sleep 22"; Start-Sleep 22
}
if (-not $ok) { "PUSH FAIL after 9" }

Start-Sleep 45
$base = "https://ramazan2005555-ai.github.io/platinum-house"
$live = (curl.exe -sS --connect-timeout 25 "$base/css/style.css" 2>$null) -join "`n"
"LIVE css bytes      = " + $live.Length
"LIVE gold hero-tail = " + $live.Contains("GOLDHEROTAIL westgold v12")
"LIVE gold hero-title= " + $live.Contains("linear-gradient(135deg, #e4c96a")
"LIVE gold navbar    = " + ($live -match "rgba\(201,168,76,0\.35\)")
"LIVE gold footer    = " + ($live -match "rgba\(201,168,76,0\.22\)")
"LIVE contain (cover=0) = " + $live.Contains("object-fit: contain") + " / " + ([regex]::Matches($live,"object-fit:\s*cover")).Count
$h = (curl.exe -sS --connect-timeout 25 "$base/" 2>$null) -join "`n"
"og:url = " + ([regex]::Match($h,'(?i)og:url" content="([^"]+)"')).Groups[1].Value
foreach($n in "main-menu.jpeg","breakfasts.jpeg","mangal.jpeg","bar-card.jpeg"){
  $c = curl.exe -sS -o NUL -w "%{http_code}" --connect-timeout 20 "$base/img/menu/$n" 2>$null
  "  " + $n + " = " + $c
}