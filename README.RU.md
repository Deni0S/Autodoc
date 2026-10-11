# Autodoc

[![Type](https://img.shields.io/badge/type-assignment-blueviolet)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)
[![Year](https://img.shields.io/badge/year-2025-lightgrey)](#)

Тестовое задание для компании **Autodoc**: iOS-приложение, отображающее новостную ленту с постраничной загрузкой.

## Требования
- Постраничная загрузка и отображение новостей
- Все запросы — на `async/await`
- Оптимизация под iPad
- Без сторонних библиотек
- Минимальная версия iOS — **16.0**, Swift — **5.10**
- UIKit, вёрстка кодом
- Использовать `DiffableDataSource` вместо устаревшего `UICollectionViewDataSource`
- В `ViewModel` использовать **state**, а не булевы флаги
- Кэш при сворачивании приложения не должен сбрасываться
- Источник данных `https://webapi.autodoc.ru/api/news/1/15` (первая цифра — номер страницы, вторая — количество элементов на странице)

## Стек
- `UIKit`
- `MVVM`
- `Combine`
- `UICollectionView`
- `CompositionalLayout`
- `DiffableDataSource`
- `async/await`
- `Background URLSession`
- `WKWebView`

## Технологии
- **UIKit** — вёрстка полностью кодом, без Storyboard/XIB
- **MVVM** — разделение UI и бизнес-логики
- **Combine** — реактивные биндинги между `ViewModel` и `ViewController`
- **State** — единое состояние экрана вместо набора булевых флагов во `ViewModel`
- **UICollectionView + CompositionalLayout** — гибкая и адаптивная раскладка ленты
- **DiffableDataSource** — безопасные анимированные обновления без ручного расчёта индексов
- **Background URLSession** — фоновая загрузка изображений и данных без сторонних библиотек
- **Cashing** — кэш сохраняется при сворачивании приложения (диск + память)
- **Pagination** — постраничная подгрузка новостей по мере скролла
- **Dark Mode** — поддержка светлой и тёмной темы
- **Localizable** — локализация строк через `Localizable.strings`
- **Tinted icon** — иконка с поддержкой tint color
- **async / await** — все сетевые запросы на структурированной конкурентности
- **WKWebView** — открытие полной новости по тапу на ячейку

## Лицензия
Проект распространяется под лицензией [MIT](./LICENSE).