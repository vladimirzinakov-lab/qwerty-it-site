# qwerty-it.ru — сайт «Владимир — 1С-программист»

Статический сайт-визитка: чистый HTML + CSS + минимум JS. Без сборки, без зависимостей, без npm.

- Сайт: https://qwerty-it.ru
- Репозиторий: https://github.com/vladimirzinakov-lab/qwerty-it-site

## Структура

```
index.html        главная: услуги, кейсы, «почему я», шаги, FAQ, отзывы, контакты
team.html         «Команда под проект» (пирамида ролей, индексируется)
404.html          страница «не найдено» (абсолютные пути, работает на любом URL)
css/style.css     общие стили для всех страниц
js/main.js        год в подвале, мобильное меню, появление блоков при скролле
img/              аватары ролей (512x512), og-image.jpg (1200x630), favicon.png (192x192)
tools/make-images.ps1  генератор og-image.jpg и favicon.png
tools/make-avatars.ps1 нарезка квадратных аватаров ролей из исходных фото
tools/check.ps1        проверка ссылок, классов и служебных файлов
tools/serve.js         локальный статический сервер без зависимостей
robots.txt        индексация + директива Sitemap
sitemap.xml       карта сайта (главная + team.html)
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
5. **Enforce HTTPS** уже включён: `http://qwerty-it.ru` редиректит на `https://` (проверено).

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
- Одна и та же навигация на всех страницах; `team.html` открыт для индексации (`index, follow`, canonical, включён в `sitemap.xml`, не закрыт в `robots.txt`).
- Блок «Кейсы» на главной: карточки «задача → стек → результат», якорь `#cases` в меню.
- HTTPS принудительный, все страницы и ассеты отдаются по `https://`.
- Единый `<body class="page-home|page-team">` — разница вёрстки страниц решается модификатором, а не копией CSS.

## Что осталось сделать по контенту

- **Кейсы** на главной — демонстрационные (в коде помечен `TODO`). Заменить на реальные проекты: задача → что сделано → результат, без непроверяемых цифр.
- **Отзывы** на главной — демонстрационные (в коде помечен `TODO`). Заменить на реальные, с согласия клиентов.
- **Фото ролей** — все шесть ролей закрыты фото; при появлении реальных людей заменить файлы в `img/` (см. раздел «Фото ролей»).
- Домен, телефон и почта указаны реальные — при смене контактов обновить `index.html` (JSON-LD, блок контактов) и `sitemap.xml`.

## Фото ролей

Все шесть ролей закрыты фотографиями — квадратные кропы 512×512 в `img/`:

| Роль | Файл | Исходник |
|---|---|---|
| Руководитель проекта | `img/pm.jpg` | `Руководитель проекта.jpg` |
| Тимлид | `img/teamlead.jpg` | готовый портрет |
| 1С-программист | `img/programmer.jpg` | `f2.jpg` |
| Консультант / бизнес-аналитик | `img/analyst.jpg` | `f4.jpg` |
| First Line Support | `img/support.jpg` | готовый портрет |
| Тестировщик | `img/qa.jpg` | `f6.jpg` |

Не использованы: `f1.jpg`, `f5.jpg`, `f7.jpg` (резерв) и `f3.jpg` — 361×209, слишком мелкое для аватара.

### Пересобрать или заменить фото

```powershell
# исходники по умолчанию: E:\_ОБМЕН\Фото для сайта
powershell -NoProfile -Command "Get-Content -LiteralPath tools\make-avatars.ps1 -Raw -Encoding UTF8 | Invoke-Expression"

# другой каталог с исходниками
powershell -NoProfile -Command "$sourceDir='D:\фото'; Get-Content -LiteralPath tools\make-avatars.ps1 -Raw -Encoding UTF8 | Invoke-Expression"
```

В таблице `$jobs` внутри скрипта для каждого фото заданы `FaceX`/`FaceY` (центр лица в исходнике) и `Box` (сторона квадрата) — так кадр встаёт по лицу. Чтобы поменять раскладку ролей, достаточно поправить пары «исходник → файл» в этой таблице.

Если фото уже квадратное, можно просто положить файл 512×512 (минимум 400×400) в `img/` и поменять `src` в `team.html` (аватар 180×180) и в блоке «Команда под проект» на главной (аватар 100×100):

```html
<img class="role-avatar avatar-photo" src="img/programmer.jpg" width="180" height="180"
     alt="1С-программист" loading="lazy" decoding="async">
```

После замены запустите `tools/check.ps1` — она поймает опечатки в путях.
