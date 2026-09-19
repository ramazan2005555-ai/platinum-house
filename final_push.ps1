param()
$ErrorActionPreference = "Continue"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$root = "C:\АРАГ\platinum-house-master"
Set-Location $root

$cssPath = Join-Path $root "css\style.css"
$css = Get-Content $cssPath -Raw -Encoding UTF8

# --- премиальный дизайн: правим style.css точечно (все без regex-ловушек) ---

# 1. hero-title: золото + статичная рамка витрины
$css = $css.Replace(".hero-title {", @"
.hero-title {
  font-family: var(--font-serif);
  font-size: clamp(2.4rem, 6vw, 4.5rem);
  font-weight: 600;
  line-height: 1.12;
  margin-bottom: 24px;
"@)

# 2. gallery-img-wrapper: тонкая золотая рамка + равноразмерная сетка без обрезки
$css = $css.Replace('.gallery-img-wrapper {', @"
.gallery-img-wrapper {
  position: relative;
  overflow: hidden;
  border-radius: 3px;
  border: 1px solid rgba(201,168,76,0.25);
"@)

# 3. gallery-img: показывать ЦЕЛИКОМ (не обрезать) + лёгкое свечение
$css = $css.Replace(".gallery-img {", @"
.gallery-img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  background: rgba(10,10,10,0.6);
"@)

# 4. lightbox: мягкое затемнение + золотой вензель рамки без сюрпризов
$css = $css.Replace(".lightbox {", @"
.lightbox {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: rgba(8,8,8,0.96);
  display: flex;
  align-items: center;
  justify-content: center;
  backdrop-filter: blur(8px);
"@)

# 5. lightbox-img: contain (фото в лайтбоксе тоже целиком, без обрезки)
$css = $css.Replace(".lightbox-img {", @"
.lightbox-img {
  max-width: 92vw;
  max-height: 88vh;
  object-fit: contain;
  border: 1px solid rgba(201,168,76,0.35);
"@)

# 6. navbar: лёгкая золотая линия внизу + блюр
$css = $css.Replace(".navbar {", @"
.navbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  border-bottom: 1px solid rgba(201,168,76,0.18);
  background: rgba(10,10,10,0.75);
  backdrop-filter: blur(12px);
"@)

# 7. hero-подзаголовок: крупнее и аккуратнее
$css = $css.Replace(".hero-subtitle {", @"
.hero-subtitle {
  font-size: clamp(0.95rem, 1.6vw, 1.15rem);
  font-weight: 300;
  letter-spacing: 2px;
  text-transform: uppercase;
"@)

Set-Content -Path $cssPath -Value $css -Encoding UTF8
Write-Output ">>> css обновлён (7 блоков дизайна)"

# --- коммит + пуш с ретраями ---
& git add -A 2>&1 | Out-Null
& git commit -m "Дизайн: премиальный стиль (золото, рамки, свечение), фото без обрезки в галерее и лайтбоксе" 2>&1 | Out-String

$done = $false
for ($i = 1; $i -le 6 -and -not $done; $i++) {
  $out = & git push origin master 2>&1 | Out-String
  if ($out -match "master -> master" -or $out -match "master->master" -or $out -match "up-to-date") {
    Write-Output ">>> PUSH OK (попытка $i)"
    $done = $true
  } else {
    Write-Output "попытка $i: сеть — повтор через 20с"
    Start-Sleep 20
  }
}

# --- живая проверка: страница, sw, css и 4 фото===
$base = "https://ramazan2005555-ai.github.io/platinum-house"
foreach ($u in @("/", "/js/main.js", "/sw.js", "/css/style.css", "/img/menu/main-menu.jpeg", "/img/menu/breakfasts.jpeg", "/img/menu/mangal.jpeg", "/img/menu/bar-card.jpeg")) {
  $code = curl.exe -sS -o NUL -w "%{http_code}" --connect-timeout 20 "$base$u" 2>$null
  "$code  $u"
}
Write-Output "--- og:url (QR-стабильность) ---"
$html = curl.exe -sS --connect-timeout 20 "$base/" 2>$null
if ($html -match 'og:url" content="([^"]+)"') { "og:url = " + $Matches[1] }
