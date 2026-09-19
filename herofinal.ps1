$ErrorActionPreference = "Continue"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo  = "C:\872C~1\PLATIN~1"
$cssShort = "C:\872C~1\PLATIN~1\css\style.css"
$swShort  = "C:\872C~1\PLATIN~1\sw.js"

Write-Output "=== 0) какие селекторы/свойства ТОЧНО есть в css (по HEAD, надёжно) ==="
$headcss = ((& git -C $repo show "HEAD:css/style.css" 2>$null) -join "`n")
"HEAD hero-title существует = " + $headcss.Contains(".hero-title {")
"HEAD hero-title золото     = " + $headcss.Contains("linear-gradient(135deg, #e4c96a")
"HEAD hero-subtitle         = " + $headcss.Contains(".hero-subtitle {")
"HEAD font-serif определён  = " + $headcss.Contains("--font-serif")
"HEAD css bytes             = " + $headcss.Length

Write-Output ""
Write-Output "=== 1) ДОПИСЫВАЮ золотой hero-title ПОВТОРНЫМ правилом в КОНЕЦ css (каскад: последнее выигрывает) ==="
$tail = @"
/* ==== GOLD HERO FINAL ==== */
.hero-title {
  font-family: var(--font-serif);
  font-weight: 600;
  font-size: clamp(2.8rem, 6vw, 5rem);
  line-height: 1.1;
  letter-spacing: 3px;
  text-align: center;
  background: linear-gradient(135deg, #e4c96a 0%, #f8edc0 42%, #cfae54 70%, #e9d183 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  color: #e9d183;
  text-shadow: 0 6px 40px rgba(228,201,106,0.45), 0 2px 90px rgba(228,201,106,0.25);
  animation: heroGoldGlow 3.2s ease-in-out infinite alternate;
}
@keyframes heroGoldGlow {
  from { text-shadow: 0 6px 30px rgba(228,201,106,0.35); }
  to   { text-shadow: 0 6px 55px rgba(228,201,106,0.65); }
}
.hero-subtitle {
  color: #efe3b8;
  letter-spacing: 4px;
  font-weight: 300;
  text-transform: uppercase;
}
"@

# читаем css с ДИСКА чтобы приклеить хвост (короткий путь работает для [IO.File])
$cssOnDisk = $null
try {
  $cssOnDisk = [System.IO.File]::ReadAllText($cssShort, [System.Text.Encoding]::UTF8)
} catch { }
if (-not $cssOnDisk) {
  Write-Output "  диск-css не прочитался -> пересоздаю из HEAD (utf8 no-BOM)"
  $cssOnDisk = ((& git -C $repo show "HEAD:css/style.css" 2>$null) -join "`r`n")
}
if (-not $cssOnDisk.Contains(".hero-title")) {
  Write-Output "  !!! в css НЕТ .hero-title — стоп, не хочу ломать"
} else {
  if ($cssOnDisk.Contains("GOLD HERO FINAL")) {
    Write-Output "  уже добавлено ранее — пропускаю (не дублирую)"
    $cssOnDisk = $cssOnDisk
  } else {
    $cssOnDisk = $cssOnDisk.TrimEnd() + "`r`n`r`n" + $tail + "`r`n"
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($cssShort, $cssOnDisk, $utf8)
    Write-Output "  GOLD HERO FINAL дописан в css/style.css. on-disk bytes = " + (Get-Item -LiteralPath $cssShort).Length
  }
}

Write-Output ""
Write-Output "=== 2) бамп SW (форс-обновление у посетителей) ==="
$sw = $null
try { $sw = [System.IO.File]::ReadAllText($swShort, [System.Text.Encoding]::UTF8) } catch { }
if ($sw) {
  $m = [regex]::Match($sw, "(?i)([A-Z_]*CACHE[A-Z_]*)\s*=\s*['""]([^'""]+)['""]")
  if ($m.Success) {
    $v = $m.Groups[2].Value
    $nv = $v + "-goldH1"
    $sw = $sw.Replace("'" + $v + "'", "'" + $nv + "'").Replace('"' + $v + '"', '"' + $nv + '"')
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($swShort, $sw, $utf8)
    Write-Output ("  sw cache: " + $v + " -> " + $nv)
  } else {
    $sw = $sw.TrimEnd() + "`r`nconst GOLDH1 = '" + (Get-Date -Format yyyyMMddHHmmss) + "';`r`n"
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($swShort, $sw, $utf8)
    Write-Output "  sw: маркер версии не найден — добавил GOLDH1 timestamp"
  }
} else {
  Write-Output "  sw.js на диске нет — пропускаю бамп"
}

Write-Output ""
Write-Output "=== 3) git: commit + push (ретраи 8x, короткий ASCII путь) ==="
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "Gold hero FINAL: золотой сияющий заголовок (gradient text) + подсветка подзаголовка, sw bump" 2>&1 | Out-String
$loc = (& git -C $repo rev-parse HEAD 2>$null)
$pushed = $false
for ($i = 1; $i -le 8; $i++) {
  $po = (& git -C $repo push origin master 2>&1 | Out-String)
  $rm = (& git -C $repo rev-parse origin/master 2>$null)
  if ($rm -eq $loc) { Write-Output ("  PUSH OK (попытка " + $i + ")"); $pushed = $true; break }
  Write-Output ("  сеть: попытка " + $i + " удалённый=" + $rm + " — сплю 22с"); Start-Sleep 22
}
if (-not $pushed) { Write-Output "  !!! PUSH НЕ прошёл за 8 попыток" }

Write-Output ""
Write-Output "=== 4) ждём Pages (~45с) и сверяем ЖИВОЕ золото ==="
Start-Sleep 50
$live = (curl.exe -sS --connect-timeout 25 "https://ramazan2005555-ai.github.io/platinum-house/css/style.css" 2>$null) -join "`n"
Write-Output ("  LIVE bytes             = " + $live.Length)
Write-Output ("  LIVE hero-title gold   = " + $live.Contains("linear-gradient(135deg, #e4c96a"))
Write-Output ("  LIVE hero glow keyframe= " + $live.Contains("heroGoldGlow"))
Write-Output ("  LIVE gold navbar       = " + ($live -match "rgba\(201,168,76,0\.25\)"))
Write-Output ("  LIVE gold gallery      = " + ($live -match "rgba\(201,168,76,0\.28\)"))
Write-Output ("  LIVE gold number       = " + $live.Contains("color: #e4c96a"))
Write-Output ("  LIVE gold footer       = " + ($live -match "rgba\(201,168,76,0\.18\)"))
Write-Output ("  LIVE contain (cover=0) = " + $live.Contains("object-fit: contain"))
Write-Output ""
Write-Output ("og:url = " + ([regex]::Match(((curl.exe -sS --connect-timeout 25 "https://ramazan2005555-ai.github.io/platinum-house/" 2>$null) -join "`n"),'(?i)og:url" content="([^"]+)"')).Groups[1].Value)