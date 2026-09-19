param([string]$Path)
$css = Get-Content $Path -Raw -Encoding UTF8
function GetRule($sel) {
  $i = $css.IndexOf($sel)
  if ($i -lt 0) { return "--- НЕТ селектора: $sel ---" }
  $e = $css.IndexOf("}", $i)
  return $css.Substring($i, $e - $i + 1)
}
"=== :root ==="; GetRule ":root"
"`n=== nav ==="; GetRule ".navbar {"
"`n=== nav-links ==="; GetRule ".nav-links {"
"`n=== hero ==="; GetRule ".hero {"
"`n=== hero-title ==="; GetRule ".hero-title {"
"`n=== hero-subtitle (offer) ==="; GetRule ".hero-subtitle {"
"`n=== gallery grid ==="; GetRule ".gallery {"
"`n=== gallery-img ==="; GetRule ".gallery-img {"
"`n=== gallery-img-wrapper ==="; GetRule ".gallery-img-wrapper {"
"`n=== gallery-overlay ==="; GetRule ".gallery-overlay {"
"`n=== lightbox ==="; GetRule ".lightbox {"
"`n=== footer ==="; GetRule ".footer {"
"`n=== btn-primary ==="; GetRule ".btn-primary {"
