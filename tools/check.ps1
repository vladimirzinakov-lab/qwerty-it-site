<#
  Проверка статического сайта qwerty-it.ru без внешних зависимостей:
    - незаполненные маркеры-заглушки и старый домен example.com
    - битые локальные ссылки и картинки
    - битые якоря (#id), в том числе ссылки вида page.html#id
    - классы, которые используются в HTML, но не описаны в css/style.css
    - баланс скобок в CSS и наличие обязательных файлов

  Запуск из корня проекта:
    powershell -NoProfile -Command "Get-Content -LiteralPath tools\check.ps1 -Raw -Encoding UTF8 | Invoke-Expression"
#>
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$root = if ((Split-Path -Leaf $scriptDir) -eq 'tools') { Split-Path -Parent $scriptDir } else { $scriptDir }
$reportPath = Join-Path $env:TEMP 'qwerty-check.log'

$errors = New-Object System.Collections.ArrayList
$checks = New-Object System.Collections.ArrayList

function Add-Error([string]$message) { [void]$errors.Add($message) }
function Add-Ok([string]$message) { [void]$checks.Add($message) }

# ---------------------------------------------------------------- обязательные файлы
$required = @(
  'index.html', 'team.html', '404.html', 'css/style.css', 'js/main.js',
  'robots.txt', 'sitemap.xml', 'CNAME', 'README.md',
  'img/og-image.jpg', 'img/favicon.png', 'img/pm.jpg', 'img/support.jpg', 'img/teamlead.jpg'
)
foreach ($item in $required) {
  if (Test-Path -LiteralPath (Join-Path $root ($item -replace '/', '\'))) {
    Add-Ok "файл на месте: $item"
  } else {
    Add-Error "НЕТ ФАЙЛА: $item"
  }
}

# ---------------------------------------------------------------- HTML
$htmlFiles = Get-ChildItem -LiteralPath $root -Filter *.html
$classesInCss = @()
$cssPath = Join-Path $root 'css\style.css'
if (Test-Path -LiteralPath $cssPath) {
  $css = Get-Content -LiteralPath $cssPath -Raw -Encoding UTF8
  $open = ([regex]::Matches($css, '\{')).Count
  $close = ([regex]::Matches($css, '\}')).Count
  if ($open -eq $close) { Add-Ok "CSS: скобки сбалансированы ($open пар)" } else { Add-Error "CSS: скобки не сбалансированы {$open / }$close" }
  foreach ($m in [regex]::Matches($css, '\.([a-zA-Z][a-zA-Z0-9_-]*)')) { $classesInCss += $m.Groups[1].Value }
  $classesInCss = $classesInCss | Sort-Object -Unique
}

$pageIds = @{}
$pagesHtml = @{}
foreach ($file in $htmlFiles) {
  $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
  $pagesHtml[$file.Name] = $content
  $ids = @()
  foreach ($m in [regex]::Matches($content, 'id="([^"]+)"')) { $ids += $m.Groups[1].Value }
  $pageIds[$file.Name] = $ids
}

foreach ($file in $htmlFiles) {
  $name = $file.Name
  $content = $pagesHtml[$name]

  if ($content -match '__HOME|__TEAM|__CHUNK') { Add-Error "$name — остались маркеры-заглушки" }
  if ($content -match 'example\.com') { Add-Error "$name — остался домен example.com" }
  if ($content -notmatch 'qwerty-it\.ru') { Add-Error "$name — нет упоминания домена qwerty-it.ru" }

  # локальные ссылки и картинки
  foreach ($m in [regex]::Matches($content, '(?:href|src)="([^"]+)"')) {
    $url = $m.Groups[1].Value
    if ($url -match '^(https?:|mailto:|tel:|data:|//)') { continue }
    $path = $url.Split('#')[0].Split('?')[0]
    if ([string]::IsNullOrWhiteSpace($path)) { continue }
    $full = Join-Path $root ($path.TrimStart('/') -replace '/', '\')
    if (-not (Test-Path -LiteralPath $full)) { Add-Error "$name — битая ссылка: $url" }
  }

  # якоря
  foreach ($m in [regex]::Matches($content, 'href="([^"]*#[^"]+)"')) {
    $url = $m.Groups[1].Value
    $parts = $url.Split('#')
    $targetPage = if ($parts[0] -eq '' -or $parts[0] -match '^(https?:|mailto:|tel:)') { $name } else { Split-Path -Leaf $parts[0] }
    $anchor = $parts[1]
    if (-not $pageIds.ContainsKey($targetPage)) { Add-Error "$name — ссылка на неизвестную страницу: $url"; continue }
    if ($pageIds[$targetPage] -notcontains $anchor) { Add-Error "$name — нет якоря #$anchor (страница $targetPage)" }
  }

  # классы, используемые в разметке
  foreach ($m in [regex]::Matches($content, 'class="([^"]+)"')) {
    foreach ($cls in ($m.Groups[1].Value -split '\s+')) {
      if ($cls -and ($classesInCss -notcontains $cls)) { Add-Error "$name — класс без стилей: .$cls" }
    }
  }

  # доступность / служебные атрибуты
  if ($content -notmatch 'aria-label="Основная навигация"') { Add-Error "$name — у навигации нет aria-label" }
  if (($content -match 'class="nav-toggle"') -and ($content -notmatch 'aria-controls="primary-nav"')) { Add-Error "$name — у бургера нет aria-controls" }

  # баланс парных тегов
  $voidTags = @('img', 'br', 'meta', 'link', 'input', 'hr', 'source')
  foreach ($tag in @('div', 'section', 'header', 'nav', 'ul', 'li', 'footer', 'main', 'body', 'html', 'details', 'summary', 'p', 'h1', 'h2', 'h3', 'a', 'span', 'button', 'script')) {
    if ($voidTags -contains $tag) { continue }
    $openCount = ([regex]::Matches($content, "<$tag(\s|>)")).Count
    $closeCount = ([regex]::Matches($content, "</$tag>")).Count
    if ($openCount -ne $closeCount) { Add-Error "$name — тег <$tag>: открыт $openCount, закрыт $closeCount" }
  }

  Add-Ok "$name — проверен"
}

# ---------------------------------------------------------------- служебные файлы
$robots = Get-Content -LiteralPath (Join-Path $root 'robots.txt') -Raw -Encoding UTF8
if ($robots -match 'Sitemap:\s*https://qwerty-it\.ru/sitemap\.xml') { Add-Ok 'robots.txt — корректный Sitemap' } else { Add-Error 'robots.txt — неверная директива Sitemap' }

$sitemap = Get-Content -LiteralPath (Join-Path $root 'sitemap.xml') -Raw -Encoding UTF8
if ($sitemap -match '<loc>https://qwerty-it\.ru/</loc>') { Add-Ok 'sitemap.xml — корректный URL' } else { Add-Error 'sitemap.xml — неверный URL' }
if ($sitemap -match '<loc>[^<]*team\.html') { Add-Error 'sitemap.xml — в карту попала noindex-страница team.html' } else { Add-Ok 'sitemap.xml — team.html не включён' }

$cname = (Get-Content -LiteralPath (Join-Path $root 'CNAME') -Raw -Encoding UTF8).Trim()
if ($cname -eq 'qwerty-it.ru') { Add-Ok 'CNAME — qwerty-it.ru' } else { Add-Error "CNAME — неожиданное значение: $cname" }

# ---------------------------------------------------------------- вывод
$lines = @()
$lines += '=== Проверки ==='
$lines += $checks
$lines += ''
$lines += '=== Ошибки ==='
if ($errors.Count -eq 0) { $lines += 'ошибок нет' } else { $lines += $errors }

$lines | Set-Content -LiteralPath $reportPath -Encoding UTF8
$lines | ForEach-Object { Write-Output $_ }
