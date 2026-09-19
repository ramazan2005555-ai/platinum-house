$ErrorActionPreference = "Stop"
$repo = "C:\872C~1\PLATIN~1"
Set-Location $repo
$cssPath = Join-Path $repo "css\style.css"
$css = Get-Content $cssPath -Raw -Encoding UTF8

# ---- маркер: hero-title золотой градиент ----
$needle1 = ".hero-title {"
if($css.Contains($needle1) -and -not $css.Contains("linear-gradient(135deg, #e4c96a")){
  $css = $css.Replace($needle1,
".hero-title {
  font-family: var(--font-serif);
  font-size: clamp(2.4rem, 6vw, 4.6rem);
  font-weight: 600;
  letter-spacing: 3px;
  line-height: 1.1;
  background: linear-gradient(135deg, #e4c96a 0%, #fff6d8 45%, #c9a84c 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  text-shadow: 0 8px 40px rgba(228,201,106,0.18);")
  "hero-title: gold OK"
} else { "hero-title: skip" }

# ---- маркер: navbar золотая нижняя линия ----
if($css.Contains(".navbar {") -and -not $css.Contains("rgba(201,168,76,0.22)")){
  $css = $css.Replace(".navbar {",
".navbar {
  border-bottom: 1px solid rgba(201,168,76,0.22);
  background: rgba(6,6,6,0.8);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);")
  "navbar: gold OK"
} else { "navbar: skip" }

# ---- маркер: галерея золотые рамки ----
if($css.Contains(".gallery-img-wrapper {") -and -not $css.Contains("rgba(201,168,76,0.28)")){
  $css = $css.Replace(".gallery-img-wrapper {",
".gallery-img-wrapper {
  border: 1px solid rgba(201,168,76,0.28);
  box-shadow: 0 24px 60px rgba(0,0,0,0.5), inset 0 0 40px rgba(201,168,76,0.04);")
  "gallery: gold frame OK"
} else { "gallery: skip" }

# ---- маркер: footer золотая линия ----
if($css.Contains(".footer {") -and -not $css.Contains("rgba(201,168,76,0.18)")){
  $css = $css.Replace(".footer {",
".footer {
  border-top: 1px solid rgba(201,168,76,0.18);")
  "footer: gold line OK"
} else { "footer: skip" }

Set-Content $cssPath $css -Encoding UTF8
Write-Output "=== проверка маркеров локально ==="
$c = Get-Content $cssPath -Raw -Encoding UTF8
"hero grad = " + $c.Contains("linear-gradient(135deg, #e4c96a")
"nav gold  = " + $c.Contains("rgba(201,168,76,0.22)")
"gal gold  = " + $c.Contains("rgba(201,168,76,0.28)")
"foot gold = " + $c.Contains("rgba(201,168,76,0.18)")
"contain   = " + $c.Contains("object-fit: contain")
