$ErrorActionPreference = "Stop"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
$repo  = "C:\872C~1\PLATIN~1"
$cssp  = "C:\872C~1\PLATIN~1\css\style.css"
$swp   = "C:\872C~1\PLATIN~1\sw.js"

$css = Get-Content -LiteralPath $cssp -Raw -Encoding UTF8
if (-not $css) { $css = ((& git -C $repo show HEAD:css/style.css 2>$null) -join "`n") }
"css диска/HEAD байт = " + $css.Length

# ---------- 1) gold hero-title (добавляем ПОВТОРНОЕ правило в конец — CSS: последнее выигрывает) ----------
$haveGold = $css.Contains("text-fill-color: transparent")
if (-not $haveGold) {
  $blockLines = @(
    ".hero-title {",
    "  font-size: clamp(2.6rem, 6vw, 4.8rem);",
    "  line-height: 1.1;",
    "  letter-spacing: 2px;",
    "  background: linear-gradient(135deg, #e4c96a 0%, #f7e8b0 45%, #c9a84c 100%);",
    "  -webkit-background-clip: text;",
    "  background-clip: text;",
    "  -webkit-text-fill-color: transparent;",
    "  text-shadow: 0 6px 60px rgba(201,168,76,0.35);",
    "}"
  )
  $block = ($blockLines -join [Environment]::NewLine) + [Environment]::NewLine
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::AppendAllText($cssp, $block, $enc)
  "hero-title gold: ДОБАВЛЕНО в конец css"
}

# повторно прочитаем css с диска и подсчитаем
$css2 = Get-Content -LiteralPath $cssp -Raw -Encoding UTF8
"gold hero на диске = " + $css2.Contains("text-fill-color: transparent")
"css байт после     = " + $css2.Length

# ---------- 2) sw.js: бамп версии кэша => форс-обновление у всех ----------
if (Test-Path -LiteralPath $swp) {
  $sw = Get-Content -LiteralPath $swp -Raw -Encoding UTF8
  $m = [regex]::Match($sw, "(['""])([A-Za-z0-9_\-]+)(['""])")
  if ($m.Success -and $m.Groups[2].Value -match "v\d|platinum|gold|ph") {
    $old = $m.Groups[2].Value
    $new = $old + "-h6"
    $swc = $sw.Replace("'$old'", "'$new'")
    Set-Content -LiteralPath $swp $swc -Encoding UTF8
    "sw: " + $old + " -> " + $new
  } else {
    "sw: паттерн не найден, доаписываю маркер"
    Add-Content -LiteralPath $swp ("`nconst H6 = " + (Get-Date -UFormat H%M%S) + ";") -Encoding UTF8
  }
}

# ---------- 3) git add + commit + push (ретраи) ----------
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "Gold v6: hero-title сияющий золотой градиент + bump sw cache" 2>&1 | Out-Null
$local = & git -C $repo rev-parse HEAD 2>$null
$ok = $false
for ($i = 1; $i -le 9; $i++) {
  & git -C $repo push origin master 2>&1 | Out-Null
  $rm = (& git -C $repo rev-parse origin/master 2>$null)
  if ($rm -eq $local) { "PUSH OK попытка " + $i; $ok = $true; break }
  "сеть: попытка " + $i + ", remote=" + $rm + ", ждём 22с"
  Start-Sleep 22
}
if (-not $ok) { "PUSH FAIL после 9" }

Write-Output ""
Write-Output "=== ждём пересборку Pages (50с) ==="
Start-Sleep 50
$base = "https://ramazan2005555-ai.github.io/platinum-house"
$live = (curl.exe -sS --connect-timeout 25 "$base/css/style.css" 2>$null) -join "`n"
"LIVE gold hero-title  = " + $live.Contains("linear-gradient(135deg, #e4c96a")
"LIVE gold hero-glow   = " + $live.Contains("text-fill-color: transparent")
"LIVE gold navbar      = " + ($live -match "rgba\(201,168,76,0\.25\)")
"LIVE gold gallery     = " + ($live -match "rgba\(201,168,76,0\.28\)")
"LIVE gold number      = " + $live.Contains("color: #e4c96a")
"LIVE gold label       = " + $live.Contains("color: #f3e2ae")
"LIVE gold lightbox-b  = " + $live.Contains("blur(12px)")
"LIVE gold footer      = " + ($live -match "rgba\(201,168,76,0\.18\)")
"LIVE object-fit cont  = " + $live.Contains("object-fit: contain")
"LIVE cover остаток    = " + ([regex]::Matches($live,"object-fit:\s*cover")).Count
