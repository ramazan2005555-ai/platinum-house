$ErrorActionPreference = "Stop"
$env:Path += ";C:\Program Files\Git\cmd;C:\Program Files\Git\bin"

# ASCII 8.3 short path — proven to work for git
$repo  = "C:\872C~1\PLATIN~1"
$cssp  = "C:\872C~1\PLATIN~1\css\style.css"
$swp   = "C:\872C~1\PLATIN~1\sw.js"

# ===== 1) read css from GIT HEAD (disk-independent, UTF8-safe via git) =====
$cssHead = (& git -C $repo show "HEAD:css/style.css" 2>$null) -join "`n"
"css bytes (from HEAD) = " + $cssHead.Length
"already gold hero?    = " + $cssHead.Contains("linear-gradient(135deg, #e4c96a")

# ===== 2) apply gold hero-title gradient =====
if (-not $cssHead.Contains("linear-gradient(135deg, #e4c96a") -and $cssHead.Contains(".hero-title {")) {
  $n = ".hero-title {"
  $inject = $n + "`r`n" +
    "  font-size: clamp(2.6rem, 6vw, 4.8rem);`r`n" +
    "  font-family: var(--font-serif);`r`n" +
    "  font-weight: 600;`r`n" +
    "  line-height: 1.1;`r`n" +
    "  letter-spacing: 2px;`r`n" +
    "  text-align: center;`r`n" +
    "  background: linear-gradient(135deg, #e4c96a 0%, #f7e8b0 40%, #c9a84c 100%);`r`n" +
    "  -webkit-background-clip: text;`r`n" +
    "  background-clip: text;`r`n" +
    "  -webkit-text-fill-color: transparent;`r`n" +
    "  text-shadow: 0 6px 50px rgba(201,168,76,0.38);"
  $cssHead = $cssHead.Replace($n, $inject)
  "hero-title: gold applied"
} else {
  "hero-title: already gold or anchor missing"
}

# ===== 3) write CSS to disk =====
$enc = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($cssp, $cssHead, $enc)
"css written to disk, bytes = " + (Get-Item -LiteralPath $cssp).Length

# ===== 4) bump SW cache version so all visitors refresh =====
if (Test-Path -LiteralPath $swp) {
  $swtxt = Get-Content $swp -Raw -Encoding UTF8
  $oldV = $null
  if ($swtxt -match "(?i)CACHE(_NAME)?\s*=\s*['""]([^'""]+)['""]") { $oldV = $Matches[2] }
  if ($oldV) {
    $newV = $oldV + "-goldH5"
    $swtxt = $swtxt.Replace($oldV, $newV)
    Set-Content -LiteralPath $swp -Value $swtxt -Encoding UTF8
    "SW cache: " + $oldV + " -> " + $newV
  } else {
    "  SW: версия-паттерн не найден, добавляю свежий маркер"
    $swtxt = $swtxt.TrimEnd() + "`nconst SW_GOLD5 = '" + (Get-Date -UFormat "%H%M%S") + "';"
    Set-Content -LiteralPath $swp -Value $swtxt -Encoding UTF8
  }
} else { "SW: sw.js не на диске (пропускаю bump)" }

# ===== 5) commit + push (retries) =====
& git -C $repo add -A 2>&1 | Out-Null
& git -C $repo commit -m "gold v5: shining gold hero-title gradient + SW cache bump (refresh all devices)" 2>&1 | Out-String
$local = (& git -C $repo rev-parse HEAD 2>$null)
$done = $false
for ($i = 1; $i -le 9; $i++) {
  & git -C $repo push origin master 2>&1 | Out-Null
  $remote = (& git -C $repo rev-parse origin/master 2>$null)
  if ($remote -eq $local) { "PUSH OK (try " + $i + ")"; $done = $true; break }
  "network: try " + $i + ", remote=" + $remote + " -- wait 22s"
  Start-Sleep 22
}
if (-not $done) { "PUSH FAILED after 9 tries" }
