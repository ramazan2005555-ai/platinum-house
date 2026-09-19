$ErrorActionPreference = "Stop"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo = "C:\872C~1\PLATIN~1"
$cssp = "C:\872C~1\PLATIN~1\css\style.css"
$swp  = "C:\872C~1\PLATIN~1\sw.js"

# ---------- 1) CSS: hero-title -> золотой градиент (читаем текущий css HEAD, правим, пишем на диск) ----------
$css = (Get-Content -LiteralPath $cssp -Raw -Encoding UTF8)
if (-not $css) { $css = ((& git -C $repo show HEAD:css/style.css 2>$null) -join "`n") }
"css на диске/c HEAD байт = " + $css.Length
$css = $css.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + @'
/* ==== GOLD hero-title: сияющий винтажный заголовок ==== */
.gold-herofix {
  display: block;
}
'@ + [Environment]::NewLine
# точечная замена существующего блока .hero-title (если он есть — добавить градиент прямо в него)
if ($css.Contains(".hero-title {") -and -not $css.Contains("gold-herofix-set")) {
  $n = ".hero-title {"
  $inj = ".hero-title {`n  font-size: clamp(2.6rem, 6vw, 4.8rem);`n  line-height: 1.14;`n  letter-spacing: 1.5px;`n  font-weight: 600;`n  font-family: var(--font-serif);`n  background: linear-gradient(135deg, #e4c96a 0%, #fff3c4 45%, #c9a84c 100%);`n  -webkit-background-clip: text;`n  background-clip: text;`n  -webkit-text-fill-color: transparent;`n  text-shadow: 0 0 60px rgba(228,201,106,0.40);`n  animation: heroGold 2.4s ease infinite alternate;`n}@media (prefers-reduced-motion: no-preference){@keyframes heroGold { from{ text-shadow:0 0 34px rgba(228,201,106,0.22);} to{ text-shadow:0 0 70px rgba(228,201,106,0.55);} }`n.hero-title {-code-ignore:1}"
  $css = $css.Replace($n, $inj.Replace("-code-ignore:1}",""))
  $css = $css.Replace(".gold-herofix {`n  display: block;`n}", "/* gold-herofix-set:1 */")
  "hero-title: gold градиент применён"
} else {
  "hero-title: уже золотой или якорь не найден (skip)"
}
[System.IO.File]::WriteAllText($cssp, $css, (New-Object System.Text.UTF8Encoding($true)))
"css записан на диск, байт = " + (Get-Item -LiteralPath $cssp).Length
"диск содержит gold hero = " + (Get-Content -LiteralPath $cssp -Raw -Encoding UTF8).Contains("linear-gradient(135deg, #e4c96a")

# ---------- 2) sw.js: бамп версии кэша (форс-обновление у посетителей) ----------
if (Test-Path -LiteralPath $swp) {
  $sw = Get-Content -LiteralPath $swp -Raw -Encoding UTF8
  $m = [regex]::Match($sw, '(["''])([^"'']*gold[^"'']*|CACHE[^"'']*)(["''])')
  if ($m.Success) {
    $old = $Matches[2]
    $new = $old + "-hero6"
    $sw = $sw.Replace("'" + $old + "'", "'" + $new + "'").Replace('"' + $old + '"', '"' + $new + '"')
    Set-Content -LiteralPath $swp $sw -Encoding UTF8
    "sw cache: " + $old + " -> " + $new
  } else {
    Set-Content -LiteralPath $swp ($sw + "`nconst CACHE_HERO6 = '" + [guid]::NewGuid().ToString("N") + "';") -Encoding UTF8
    "sw: добавлен CACHE_HERO6 маркер (refresh-force)"
  }
} else { "sw.js нет на диске — skip" }

# ---------- 3) git: add + commit + push с ретраями ----------
Set-Location $repo
& git add -A 2>$null | Out-Null
& git commit -m "Gold v6: hero-title сияющий золотой градиент + pulse; sw bump hero6 (форс-обновление у всех)" 2>$null | Out-Null
$local = (& git rev-parse HEAD 2>$null)
for ($i = 1; $i -le 7; $i++) {
  & git push origin master 2>$null | Out-Null
  $remote = (& git rev-parse origin/master 2>$null)
  if ($remote -eq $local) { "PUSH OK (попытка $i)"; break }
  "сеть: попытка $i, remote=$remote — ждём 22с"; Start-Sleep 22
}
(
"=== live: золотой hero? ==="
)