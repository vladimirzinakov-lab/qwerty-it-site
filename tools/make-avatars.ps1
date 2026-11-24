<#
  Нарезка квадратных аватаров под роли команды.
  Результат: img/programmer.jpg, img/analyst.jpg, img/qa.jpg — 512x512, JPEG q90.

  Источник по умолчанию: E:\_ОБМЕН\Фото для сайта
  Запуск из корня проекта:
    powershell -NoProfile -Command "Get-Content -LiteralPath tools\make-avatars.ps1 -Raw -Encoding UTF8 | Invoke-Expression"

  Другой источник:
    $sourceDir = 'D:\фото'; Get-Content -LiteralPath tools\make-avatars.ps1 -Raw -Encoding UTF8 | Invoke-Expression

  Если меняете фото — поправьте FaceX/FaceY (центр лица в исходнике) и Box (сторона квадрата).
#>
Add-Type -AssemblyName System.Drawing

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$root = if ((Split-Path -Leaf $scriptDir) -eq 'tools') { Split-Path -Parent $scriptDir } else { $scriptDir }
$imgDir = Join-Path $root 'img'
if (-not $sourceDir) { $sourceDir = 'E:\_ОБМЕН\Фото для сайта' }

$outSize = 512

$jobs = @(
  # исходники из папки обмена
  @{ Src = 'f2.jpg'; SrcDir = $sourceDir; Out = 'programmer.jpg'; FaceX = 445; FaceY = 200; Box = 560 },
  @{ Src = 'f4.jpg'; SrcDir = $sourceDir; Out = 'analyst.jpg';    FaceX = 380; FaceY = 120; Box = 384 },
  @{ Src = 'f6.jpg'; SrcDir = $sourceDir; Out = 'qa.jpg';         FaceX = 390; FaceY = 150; Box = 386 },
  # портреты: источник из папки обмена либо оригинал из img/_orig
  @{ Src = 'Руководитель проекта.jpg'; SrcDir = $sourceDir; Out = 'pm.jpg'; FaceX = 245; FaceY = 70; Box = 300 },
  @{ Src = 'teamlead.jpg'; SrcDir = $imgDir; Out = 'teamlead.jpg'; FaceX = 608; FaceY = 180; Box = 790 },
  @{ Src = 'support.jpg';  SrcDir = $imgDir; Out = 'support.jpg';  FaceX = 410; FaceY = 210; Box = 808 }
)

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]85)

foreach ($job in $jobs) {
  $srcPath = Join-Path $job.SrcDir $job.Src
  if (-not (Test-Path -LiteralPath $srcPath)) {
    Write-Output ('НЕТ ИСХОДНИКА: ' + $srcPath)
    continue
  }

  # для портретов из img/ оригинал сохраняем в img/_orig, чтобы пересборка была неразрушающей
  if ($job.SrcDir -eq $imgDir) {
    $backupDir = Join-Path $imgDir '_orig'
    if (-not (Test-Path -LiteralPath $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
    $backupPath = Join-Path $backupDir $job.Src
    if (-not (Test-Path -LiteralPath $backupPath)) { Copy-Item -LiteralPath $srcPath -Destination $backupPath }
    $srcPath = $backupPath
  }

  $src = [System.Drawing.Image]::FromFile($srcPath)
  $srcW = $src.Width
  $srcH = $src.Height

  $box = [Math]::Min($job.Box, [Math]::Min($srcW, $srcH))
  $left = [int][Math]::Max(0, [Math]::Min($srcW - $box, $job.FaceX - [int]($box / 2)))
  $top = [int][Math]::Max(0, [Math]::Min($srcH - $box, $job.FaceY - [int]($box / 2)))

  $crop = New-Object System.Drawing.Rectangle($left, $top, $box, $box)
  $target = New-Object System.Drawing.Rectangle(0, 0, $outSize, $outSize)

  $dst = New-Object System.Drawing.Bitmap($outSize, $outSize)
  $g = [System.Drawing.Graphics]::FromImage($dst)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.DrawImage($src, $target, $crop, [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()
  # отпускаем исходный файл: он может совпадать с выходным (пересборка портретов)
  $src.Dispose()

  $outPath = Join-Path $imgDir $job.Out
  $tmpPath = $outPath + '.tmp'
  $dst.Save($tmpPath, $jpegCodec, $encoderParams)
  $dst.Dispose()
  Move-Item -LiteralPath $tmpPath -Destination $outPath -Force

  Write-Output ('{0} -> {1}  (кроп {2}x{2} из {3}x{4}, left={5}, top={6})' -f $job.Src, $job.Out, $box, $srcW, $srcH, $left, $top)
}
