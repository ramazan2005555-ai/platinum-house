param()
$repo = "C:\АРАГ\platinum-house-master"
Set-Location $repo

# ============ 1) Читаем САМЫЙ СВЕЖИЙ style.css с диска ============
$css = Get-Content "css\style.css" -Raw -Encoding UTF8
$orig = $css

# ============ 2) точечные премиум-замены (только реальные куски, что есть) ============

# 2.1 Прелоадер: свечение + золотой шрифт
$css = $css.Replace(".preloader-text {", ".preloader-text {`n  font-family: var(--font-serif);`n  letter-spacing: 8px;`n  color: var(--gold-light);")

# 2.2 Navbar: тёмный люкс с blur + золотая нижняя линия
$css = $css.Replace(".navbar {", ".navbar {`n  background: rgba(8,8,8,0.75);`n  backdrop-filter: blur(14px);`n  -webkit-backdrop-filter: blur(14px);`n  border-bottom: 1px solid rgba(201,168,76,0.22);")

# 2.3 Nav-link: золотые ховеры
$css = $css.Replace(".nav-link {", ".nav-link {`n  letter-spacing: 1.5px;`n  text-transform: uppercase;`n  font-size: 0.78rem;")

# 2.4 Hero: истинно премиальный заголовок
$css = $css.Replace(".hero-title {", ".hero-title {`n  font-family: var(--font-serif);`n  font-size: clamp(2.4rem, 6.5vw, 5rem);`n  font-weight: 600;`n  letter-spacing: 2px;`n  line-height: 1.1;`n  background: linear-gradient(135deg, #e4c96a 0%, #c9a84c 40%, #a8882f 55%, #e4c96a 100%);`n  -webkit-background-clip: text;`n  background-clip: text;`n  -webkit-text-fill-color: transparent;`n  text-shadow: 0 2px 40px rgba(201,168,76,0.25);")

# 2.5 Кнопка: золотая обводка с ховер-заливкой
$css = $css.Replace(".btn-primary {", ".btn-primary {`n  border: 1px solid var(--gold);`n  color: var(--gold-light);`n  letter-spacing: 3px;`n  padding: 15px 46px;`n  background: linear-gradient(135deg, rgba(201,168,76,0.06), rgba(201,168,76,0.02));`n  box-shadow: 0 0 24px rgba(201,168,76,0.08), inset 0 0 24px rgba(201,168,76,0.05);")

# 2.6 Галерея: витрина-люкс без обрезки (contain уже есть — добавим рамки и тени)
$css = $css.Replace(".gallery-img-wrapper {", ".gallery-img-wrapper {`n  border-radius: 3px;`n  border: 1px solid rgba(201,168,76,0.28);`n  box-shadow: 0 24px 64px rgba(0,0,0,0.55), inset 0 0 0 1px rgba(0,0,0,0.4);`n  background: var(--black-2);")

# 2.7 gallery-img: contain (гарантированно; заменяем cover->contain глобально)
$css = $css.Replace("object-fit: cover;", "object-fit: contain;")

# 2.8 Подпись галереи: золотой номер + серифные названия
$css = $css.Replace(".gallery-label {", ".gallery-label {`n  font-family: var(--font-serif);`n  font-size: 0.95rem;`n  letter-spacing: 3px;`n  color: var(--gold-light);")
$css = $css.Replace(".gallery-number {", ".gallery-number {`n  color: var(--gold);`n  font-size: 府0.8rem;")

# 2.9 Лайтбокс: деликатный blur + золотая рамка фото
$css = $css.Replace(".lightbox {", ".lightbox {`n  background: rgba(6,6,6,0.92);`n  backdrop-filter: blur(10px);`n  -webkit-backdrop-filter: blur(10px);")
$css = $css.Replace(".lightbox-img {", ".lightbox-img {`n  object-fit: contain;`n  border: 1px solid rgba(201,168,76,0.35);`n  box-shadow: 0 0 80px rgba(201,168,76,0.15);")

# 2.10 Footer: золотая линия сверху
$css = $css.Replace(".footer {", ".footer {`n  border-top: 1px solid rgba(201,168,76,0.18);")

# ============ 3) запись ============
Set-Content "css\style.css" -Value $css -Encoding UTF8
Write-Output "=== правки применены. Разница байт: " + ($css.Length - $orig.Length) + " ==="
$after = Get-Content "css\style.css" -Raw -Encoding UTF8
Write-Output "=== осталось cover (должно быть 0): " + ([regex]::Matches($after, "object-fit:\s*cover")).Count + " ==="
Write-Output "=== добавлено contain: " + ([regex]::Matches($after, "object-fit:\s*contain")).Count + " ==="
Write-Output "=== градиент hero-title добавлен: " + ($after -match "linear-gradient\(135deg, #e4c96a") + " ==="
