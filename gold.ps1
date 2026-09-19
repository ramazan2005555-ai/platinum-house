$ErrorActionPreference = "Stop"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$root = "C:\АРАГ\platinum-house-master"
$cssPath = Join-Path $root "css\style.css"

$css = Get-Content $cssPath -Raw -Encoding UTF8
if (-not $css) { Write-Output "ERROR: css null"; exit 1 }

# --- helper: single-line insertion after a selector brace ---
function InsertAfter([string]$anchor, [string]$lines) {
  $script:css = $script:css.Replace($anchor, $anchor + $lines)
}

# ============ 1) HERO: золотой люкс ============
InsertAfter ".hero-title {" "`n  font-size: clamp(2.6rem, 6vw, 4.8rem); letter-spacing: 2px; line-height: 1.1; background: linear-gradient(135deg, #e4c96a 0%, #f7e8b0 40%, #c9a84c 100%); -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; text-shadow: 0 6px 60px rgba(201,168,76,0.35);"
InsertAfter ".hero-subtitle {" "`n  letter-spacing: 5px; font-weight: 400;"
InsertAfter ".hero-divider {" "`n  width: 110px; height: 1px; background: linear-gradient(90deg, transparent, #e4c96a, transparent); box-shadow: 0 0 18px rgba(228,201,106,0.7);"

# ============ 2) NAVBAR: золото ============
InsertAfter ".navbar {" "`n  border-bottom: 1px solid rgba(201,168,76,0.25); background: rgba(7,7,7,0.75); backdrop-filter: blur(14px); -webkit-backdrop-filter: blur(14px);"
InsertAfter ".nav-link {" "`n  color: #fff2cc; font-size: 0.78rem; letter-spacing: 2.5px; text-transform: uppercase;"
InsertAfter ".nav-link:hover," ""

# ============ 3) GALLERY ============
if ($css.Contains(".gallery-img-wrapper {") -and -not ($css -match "rgba\(201,168,76,0\.28\)")) {
  InsertAfter ".gallery-img-wrapper {" "`n  border: 1px solid rgba(201,168,76,0.28); border-radius: 6px; box-shadow: 0 24px 60px rgba(0,0,0,0.6), inset 0 0 0 1px rgba(201,168,76,0.06); background: radial-gradient(120% 100% at 50% 0%, rgba(201,168,76,0.08), rgba(0,0,0,0.9) 75%);"
}
if ($css.Contains(".gallery-number {")) {
  InsertAfter ".gallery-number {" "`n  color: var(--gold); font-family: var(--font-serif); letter-spacing: 3px;"
}
if ($css.Contains(".gallery-label {")) {
  InsertAfter ".gallery-label {" "`n  font-family: var(--font-serif); letter-spacing: 0.12em; color: #f3e2ae;"
}

# ============ 4) LIGHTBOX ============
if ($css.Contains(".lightbox {")) {
  InsertAfter ".lightbox {" "`n  background: rgba(4,4,4,0.95); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);"
}
if ($css.Contains(".lightbox-img {")) {
  InsertAfter ".lightbox-img {" "`n  object-fit: contain; max-height: 88vh; border-radius: 6px; box-shadow: 0 0 120px rgba(201,168,76,0.12), inset 0 0 0 1px rgba(201,168,76,0.20);"
}

# ============ 5) FOOTER ============
if ($css.Contains(".footer {")) {
  InsertAfter ".footer {" "`n  border-top: 1px solid rgba(201,168,76,0.18);"
}

# ============ 6) гарантия: contain вместо cover ============
$css = [regex]::Replace($css, "object-fit:\s*cover;", "object-fit: contain;")

Set-Content $cssPath $css -Encoding UTF8
Write-Output ("CSS bytes: " + (Get-Item $cssPath).Length)
Write-Output ("cover left: " + ([regex]::Matches($css,"object-fit:\s*cover")).Count)
Write-Output ("gold markers: title=" + $css.Contains("linear-gradient(135deg, #e4c96a") + " nav=" + $css.Contains("rgba(201,168,76,0.25)") + " gal=" + ($css -match "rgba\(201,168,76,0\.28\)") + " lb=" + ($css.Contains("blur(12px)")) + " foot=" + ($css.Contains("rgba(201,168,76,0.18)")))

# ---------- GIT: add + commit + push с ретраями ----------
Set-Location $root
git add -A 2>&1 | Out-Null
git commit -m "Дизайн v4: золотой люкс — сияющий заголовок, золотые рамки галереи, деликатный blur-лайтбокс" 2>&1 | Out-Null

$pushOK = $false
for ($i = 1; $i -le 7; $i++) {
  $out = git push origin master 2>&1 | Out-String
  if ($out -match "master -> master|master.*up-to-date|Everything up-to-date") { Write-Output "PUSH OK (попытка $i)"; $pushOK = $true; break }
  Write-Output "сеть — повтор $i; 20с"; Start-Sleep 20
}
if (-not $pushOK) { Write-Output "PUSH FAILED после 7 попыток" }
