/* qwerty-it.ru — общий скрипт для всех страниц:
   год в подвале, мобильное меню, появление блоков при скролле. */
(function () {
  'use strict';

  /* Текущий год в подвале */
  var yearEl = document.getElementById('year');
  if (yearEl) {
    yearEl.textContent = new Date().getFullYear();
  }

  /* Мобильное меню: бургер + закрытие по ссылке и по Esc */
  var toggle = document.querySelector('.nav-toggle');
  var navList = document.getElementById('primary-nav');

  function setNav(open) {
    if (!toggle || !navList) {
      return;
    }
    navList.classList.toggle('open', open);
    toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
  }

  if (toggle && navList) {
    toggle.addEventListener('click', function () {
      setNav(!navList.classList.contains('open'));
    });

    navList.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', function () {
        setNav(false);
      });
    });

    document.addEventListener('keydown', function (event) {
      if (event.key === 'Escape' && navList.classList.contains('open')) {
        setNav(false);
        toggle.focus();
      }
    });
  }

  /* Появление блоков .reveal */
  var items = document.querySelectorAll('.reveal');
  var reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  if (!reduced && 'IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12 });

    items.forEach(function (item) { io.observe(item); });
  } else {
    items.forEach(function (item) { item.classList.add('visible'); });
  }
})();
