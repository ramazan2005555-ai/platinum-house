$ErrorActionPreference = "Stop"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$cssShort = "C:\872C~1\PLATIN~1\css\style.css"

# --- читаем css прямо из git HEAD (не зависит от FS-пути и кодировки диска) ---
$cssText = (& git -C $repo show "HEAD:css/style.css" 2>&1 | Out-String)
if (-not $cssText) { Write-Output "ERROR: git show пуст"; exit 1 }
[System.Text.RegularExpressions.Regex]::Options

# ============ HERO: золотой люкс ============
$cssText = $cssText.Replace(".hero-title {", ".hero-title {`n  font-size: clamp(2.6rem, 6vw, 4.8rem); letter-spacing: 2px; line-height: 1.1; background: linear-gradient(135deg, #e4c96a 0%, #f7e8b0 40%, #c9a84c 100%); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; text-shadow: 0 6px 60px rgba(201,168,76,0.35);")
$cssText = $cssText.Replace(".hero-subtitle {", ".hero-subtitle {`n  letter-spacing: 5px; font-weight: 400;")
$cssText = $cssText.Replace(".hero-divider {", ".hero-divider {`n  width: 110px; height: 1px; background: linear-gradient(90deg, transparent, #e4c96a, transparent); box-shadow: 0 0 18px rgba(228,201,106,0.7);")

# ============ NAVBAR ============
if ($cssText.Contains(".navbar {")) {
  $cssText = $cssText.Replace(".navbar {", ".navbar {`n  border-bottom: 1px solid rgba(201,168,76,0.25); background: rgba(7,7,7,0.75); backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px);")
}
if ($cssText.Contains(".nav-link {")) {
  $cssText = $cssText.Replace(".nav-link {", ".nav-link {`n  font-size: 0.78rem; letter-spacing: 2.5px; text-transform: uppercase; color: #f3e8c4;")
}

# ============ GALLERY: золотые рамки ============
if ($cssText.Contains(".gallery-img-wrapper {") -and -not ($cssText -match "rgba\(201,168,76,0\.28\)")) {
  $cssText = $cssText.Replace(".gallery-img-wrapper {", ".gallery-img-wrapper {`n  border: 1px solid rgba(201,168,76,0.28); border-radius: 6px; box-shadow: 0 24px 60px rgba(0,0,0,0.6), inset 0 0 0 1px rgba(201,168,76,0.06); background: radial-gradient(120% 100% at 50% 0%, rgba(201,168,76,0.08), rgba(0,0,0,0.9) 75%);")
}
if ($cssText.Contains(".gallery-number {")) {
  $cssText = $cssText.Replace(".gallery-number {", ".gallery-number {`n  color: #e4c96a; font-family: 'Playfair Display', Georgia, serif; letter-spacing: 3px;")
}
if ($cssText.Contains(".gallery-label {")) {
  $cssText = $cssText.Replace(".gallery-label {", ".gallery-label {`n  font-family: 'Playfair Display', Georgia, serif; letter-spacing: 0.12em; text-transform: uppercase; color: #f3e2ae;")
}

# ============ LIGHTBOX ============
if ($cssText.Contains(".lightbox {")) {
  $cssText = $cssText.Replace(".lightbox {", ".lightbox {`n  background: rgba(4,4,4,0.95); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);")
}
if ($cssText.Contains(".lightbox-img {")) {
  $cssText = $cssText.Replace(".lightbox-img {", ".lightbox-img {`n  object-fit: contain; max-height: 88vh; border-radius: 6px; box-shadow: 0 0 120px rgba(201,168,76,0.12), inset 0 0 0 1px rgba(201,168,76,0.20);")
}

# ============ FOOTER ============
if ($cssText.Contains(".footer {")) {
  $cssText = $cssText.Replace(".footer {", ".footer {`n  border-top: 1px solid rgba(201,168,76,0.18);")
}

# ============ гарантия: contain ============
$cssText = [regex]::Replace($cssText, "object-fit:\s*cover;", "object-fit: contain;")

# --- запись на диск (короткий путь, UTF8 c BOM чтобы PS/браузер читали верно) ---
$enc = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($cssShort, $cssText, $enc)

Write-Output ("disk css bytes = " + (Get-Item $cssShort).Length)
Write-Output ("cover left     = " + ([regex]::Matches($cssText,"object-fit:\s*cover")).Count)
Write-Output ("gold title     = " + $cssText.Contains("linear-gradient(135deg, #e4c96a"))
Write-Output ("gold nav       = " + $cssText.Contains("rgba(201,168,76,0.25)"))
Write-Output ("gold gallery   = " + ($cssText -match "rgba\(201,168,76,0\.28\)"))
Write-Output ("gold number    = " + $cssText.Contains("color: #e4c96a"))
Write-Output ("gold footer    = " + $cssText.Contains("rgba(201,168,76,0.18)"))

# ---------- GIT ----------
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "Design v4 gold: luxe hero gradient, gold gallery/number/label, gold footer line, lightbox blur (ASCII-ru safe)" 2>&1 | Out-String
$ok = $false
for ($i = 1; $i -le 7; $i++) {
  $out = (& git -C $repo push origin master 2>&1 | Out-String)
  if ($out -match "master -> master|master.*master|up-to-date|Everything") { Write-Output ("PUSH OK (try " + $i + ")"); $ok = $true; break }
  Write-Output ("network retry " + $i + " ..."); Start-Sleep 20
}
if (-not $ok) { Write-Output "PUSH FAIL after 7 tries" }
