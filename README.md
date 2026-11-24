# qwerty-it.ru — сайт «Владимир — 1С-программист»

Статический сайт-визитка: чистый HTML + CSS + минимум JS. Без сборки, без зависимостей, без npm.

- Сайт: https://qwerty-it.ru
- Репозиторий: https://github.com/vladimirzinakov-lab/qwerty-it-site

## Структура

```
index.html        главная: услуги, «почему я», шаги, FAQ, отзывы, контакты
team.html         «Команда под проект» (пирамида ролей, закрыта от индексации)
404.html          страница «не найдено» (абсолютные пути, работает на любом URL)
css/style.css     общие стили для всех страниц
js/main.js        год в подвале, мобильное меню, появление блоков при скролле
img/              фото ролей, og-image.jpg (1200x630), favicon.png (192x192)
tools/make-images.ps1  генератор og-image.jpg и favicon.png
tools/check.ps1        проверка ссылок, классов и служебных файлов
tools/serve.js         локальный статический сервер без зависимостей
robots.txt        индексация + директива Sitemap
sitemap.xml       карта сайта (только главная)
CNAME             домен для GitHub Pages
```

## Локальный просмотр

Достаточно открыть `index.html` в браузере. Для просмотра «как на сервере» (с корректным 404):

```powershell
node tools\serve.js 8123     # → http://localhost:8123
# или
python -m http.server 8000   # → http://localhost:8000
```

## Проверка перед публикацией

```powershell
powershell -NoProfile -Command "Get-Content -LiteralPath tools\check.ps1 -Raw -Encoding UTF8 | Invoke-Expression"
```

Скрипт проверяет: незаполненные маркеры, остатки `example.com`, битые локальные ссылки и картинки, якоря (включая `page.html#id`), классы без стилей в CSS, баланс скобок в CSS и парных тегов в HTML, наличие обязательных файлов, директивы `robots.txt`/`sitemap.xml`/`CNAME`. Отчёт дублируется в `%TEMP%\qwerty-check.log`.

## Публикация на GitHub Pages

1. `git push -u origin main`
2. В репозитории: **Settings → Pages → Source: Deploy from a branch → main / (root)**.
3. Файл `CNAME` уже содержит `qwerty-it.ru` — домен подхватится автоматически.
4. У регистратора DNS: `A`-записи на IP GitHub Pages (`185.199.108.153`, `.109.153`, `.110.153`, `.111.153`) и `CNAME` для `www` → `vladimirzinakov-lab.github.io`.
5. Включите **Enforce HTTPS** после выпуска сертификата.

## Перегенерация картинок

```powershell
powershell -ExecutionPolicy Bypass -File tools\make-images.ps1
```

Если политика выполнения блокирует `.ps1`:

```powershell
powershell -NoProfile -Command "Get-Content -LiteralPath tools\make-images.ps1 -Raw -Encoding UTF8 | Invoke-Expression"
```

## Что уже учтено

- Домен `qwerty-it.ru` во всех мета-тегах, canonical, JSON-LD, `sitemap.xml`, `robots.txt`.
- Open Graph / Twitter Card с реальным `img/og-image.jpg` 1200×630 — корректное превью в Telegram, WhatsApp, VK.
- Локальные фото (`img/*.jpg`) вместо внешнего хотлинка Unsplash; `width`/`height` + `loading="lazy"` + `decoding="async"`.
- Общий `css/style.css` для всех страниц — стили больше не дублируются.
- Доступность: `aria-label` у навигации, `aria-controls`/`aria-expanded` у бургера, `aria-current="page"` у активного пункта, `aria-hidden` у декоративных emoji, закрытие меню по Esc.
- Одна и та же навигация на всех страницах, `team.html` помечен `noindex` и исключён из `sitemap.xml`.
- Единый `<body class="page-home|page-team">` — разница вёрстки страниц решается модификатором, а не копией CSS.

## Что осталось сделать по контенту

- **Отзывы** на главной — демонстрационные (в коде помечены `TODO`). Заменить на реальные, с согласия клиентов.
- **Роли на `team.html`** — модель команды; при появлении реальных людей добавить их фото в `img/` и подставить в разметку.
- Домен и почта/телефон указаны реальные — при смене контактов обновить `index.html` (JSON-LD, блок контактов) и `sitemap.xml`.
