<#
  Генерация картинок для сайта qwerty-it.ru:
    img/og-image.jpg — превью 1200x630 для Open Graph (Telegram, WhatsApp, VK)
    img/favicon.png  — иконка 192x192 для apple-touch-icon

  Запуск (из корня проекта):
    powershell -ExecutionPolicy Bypass -File tools\make-images.ps1

  Если политика выполнения блокирует файлы .ps1, используйте:
    powershell -NoProfile -Command "Get-Content -LiteralPath tools\make-images.ps1 -Raw -Encoding UTF8 | Invoke-Expression"
#>
Add-Type -AssemblyName System.Drawing

# скрипт лежит в <корень>/tools; поддерживаем и запуск через Invoke-Expression,
# когда $PSScriptRoot не определён
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$root = if ((Split-Path -Leaf $scriptDir) -eq 'tools') { Split-Path -Parent $scriptDir } else { $scriptDir }
$imgDir = Join-Path $root 'img'
if (-not (Test-Path -LiteralPath $imgDir)) { New-Item -ItemType Directory -Path $imgDir | Out-Null }

function Get-HtmlColor([string]$hex) {
  return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

$bg      = Get-HtmlColor '#0f172a'
$accent  = Get-HtmlColor '#38bdf8'
$accent2 = Get-HtmlColor '#22c55e'
$text    = Get-HtmlColor '#e2e8f0'
$muted   = Get-HtmlColor '#94a3b8'
$border  = Get-HtmlColor '#334155'

# ----------------------------------------------------------------- og-image
$w = 1200
$h = 630
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.Clear($bg)

# мягкое голубое свечение справа сверху
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(640, -300, 940, 940)
$glow = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glow.CenterColor    = [System.Drawing.Color]::FromArgb(80, $accent)
$glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $accent))
$g.FillPath($glow, $glowPath)

# акцентная полоса слева
$barBrush = New-Object System.Drawing.SolidBrush($accent)
$g.FillRectangle($barBrush, 80, 148, 10, 300)

# заголовок подгоняем по ширине, чтобы не обрезался
$titleText = 'Владимир — 1С-программист'
$maxWidth  = $w - 132 - 80
$titleSize = 54
$titleFont = New-Object System.Drawing.Font('Segoe UI', $titleSize, [System.Drawing.FontStyle]::Bold)
while (($g.MeasureString($titleText, $titleFont).Width -gt $maxWidth) -and ($titleSize -gt 24)) {
  $titleFont.Dispose()
  $titleSize -= 2
  $titleFont = New-Object System.Drawing.Font('Segoe UI', $titleSize, [System.Drawing.FontStyle]::Bold)
}
$subFont   = New-Object System.Drawing.Font('Segoe UI', 28, [System.Drawing.FontStyle]::Regular)
$priceFont = New-Object System.Drawing.Font('Segoe UI', 36, [System.Drawing.FontStyle]::Bold)
$smallFont = New-Object System.Drawing.Font('Segoe UI', 24, [System.Drawing.FontStyle]::Regular)

$textBrush  = New-Object System.Drawing.SolidBrush($text)
$mutedBrush = New-Object System.Drawing.SolidBrush($muted)
$accBrush   = New-Object System.Drawing.SolidBrush($accent)
$acc2Brush  = New-Object System.Drawing.SolidBrush($accent2)

$g.DrawString($titleText, $titleFont, $textBrush, 132, 150)
$g.DrawString('20+ лет опыта · Официальный партнёр 1С', $subFont, $mutedBrush, 132, 246)
$g.DrawString('Доработка · Поддержка · Интеграции · Автоматизация', $smallFont, $mutedBrush, 132, 306)
$g.DrawString('2 500 ₽ / час', $priceFont, $acc2Brush, 132, 384)

$linePen = New-Object System.Drawing.Pen($border, 2)
$g.DrawLine($linePen, 132, 486, 1068, 486)
$g.DrawString('qwerty-it.ru', $smallFont, $accBrush, 132, 508)

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]92)
$ogPath = Join-Path $imgDir 'og-image.jpg'
$bmp.Save($ogPath, $jpegCodec, $encoderParams)

# ------------------------------------------------------------------ favicon
$size = 192
$fav  = New-Object System.Drawing.Bitmap($size, $size)
$fg   = [System.Drawing.Graphics]::FromImage($fav)
$fg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$fg.Clear([System.Drawing.Color]::Transparent)

$rect = New-Object System.Drawing.Rectangle(8, 8, 176, 176)
$radius = 40
$roundPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$roundPath.AddArc($rect.X, $rect.Y, $radius, $radius, 180, 90)
$roundPath.AddArc($rect.Right - $radius, $rect.Y, $radius, $radius, 270, 90)
$roundPath.AddArc($rect.Right - $radius, $rect.Bottom - $radius, $radius, $radius, 0, 90)
$roundPath.AddArc($rect.X, $rect.Bottom - $radius, $radius, $radius, 90, 90)
$roundPath.CloseFigure()

$fillBrush = New-Object System.Drawing.SolidBrush($bg)
$strokePen = New-Object System.Drawing.Pen($accent, 8)
$fg.FillPath($fillBrush, $roundPath)
$fg.DrawPath($strokePen, $roundPath)

$letterFont = New-Object System.Drawing.Font('Segoe UI', 92, [System.Drawing.FontStyle]::Bold)
$centered   = New-Object System.Drawing.StringFormat
$centered.Alignment     = [System.Drawing.StringAlignment]::Center
$centered.LineAlignment = [System.Drawing.StringAlignment]::Center
$box = New-Object System.Drawing.RectangleF(0, 0, $size, $size)
$fg.DrawString('В', $letterFont, $accBrush, $box, $centered)

$favPath = Join-Path $imgDir 'favicon.png'
$fav.Save($favPath, [System.Drawing.Imaging.ImageFormat]::Png)

# --------------------------------------------------------------- завершение
$fg.Dispose(); $fav.Dispose(); $centered.Dispose(); $letterFont.Dispose()
$fillBrush.Dispose(); $strokePen.Dispose(); $roundPath.Dispose()
$linePen.Dispose(); $titleFont.Dispose(); $subFont.Dispose(); $priceFont.Dispose(); $smallFont.Dispose()
$textBrush.Dispose(); $mutedBrush.Dispose(); $accBrush.Dispose(); $acc2Brush.Dispose(); $barBrush.Dispose()
$glow.Dispose(); $glowPath.Dispose(); $g.Dispose(); $bmp.Dispose()

Write-Output 'Сгенерировано:'
foreach ($file in @($ogPath, $favPath)) {
  $info = Get-Item -LiteralPath $file
  Write-Output ('  {0}  ({1} байт)' -f $info.Name, $info.Length)
}
