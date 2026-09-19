$cssPath = Join-Path $env:USERPROFILE "..\..\..\АРАГ\platinum-house-master\css\style.css"
# simpler: rebuild from absolute
$root = "C:\АРАГ\platinum-house-master"
$css = Get-Content (Join-Path $root "css\style.css") -Raw -Encoding UTF8
function Get-Rule($css, $sel) {
  $i = $css.IndexOf($sel)
  if ($i -lt 0) { return "(нет: $sel)" }
  $e = $css.IndexOf("}", $i)
  return $css.Substring($i, $e - $i + 1)
}
"=== HERO блоки ==="
Get-Rule $css ".hero {"
Get-Rule $css ".hero " -ErrorAction SilentlyContinue
"=== :root догрузка (золото) ==="
Get-Rule $css ":root"
"=== галерея ключевые ==="
Get-Rule $css ".gallery {"
Get-Rule $css ".gallery-img {"
Get-Rule $css ".gallery-img-wrapper {"
Get-Rule $css ".footer {"
