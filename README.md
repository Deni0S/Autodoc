# Autodoc

[![Type](https://img.shields.io/badge/type-assignment-blueviolet)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)
[![Year](https://img.shields.io/badge/year-2025-lightgrey)](#)

A test assignment for **Autodoc**: an iOS app that displays a news feed with paginated loading.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Readme/Dark.gif">
  <source media="(prefers-color-scheme: light)" srcset="Readme/Light.gif">
  <img alt="Demo" src="Readme/Light.gif" width="300">
</picture>

## Requirements
- Paginated loading and display of news
- All requests use `async/await`
- Optimized for iPad
- No third-party libraries
- Minimum iOS version — **16.0**, Swift — **5.10**
- UIKit, layout in code
- Use `DiffableDataSource` instead of the legacy `UICollectionViewDataSource`
- Use a **state** in the `ViewModel` instead of boolean flags
- Cache must not be reset when the app goes to background
- Data source: `https://webapi.autodoc.ru/api/news/1/15` (the first number is the page, the second is the number of items per page)

## Stack
- `UIKit`
- `MVVM`
- `Combine`
- `UICollectionView`
- `CompositionalLayout`
- `DiffableDataSource`
- `async/await`
- `Background URLSession`
- `WKWebView`

## Technologies
- **UIKit** — layout entirely in code, no Storyboard/XIB
- **MVVM** — separation of UI and business logic
- **Combine** — reactive bindings between the `ViewModel` and the `ViewController`
- **State** — a single screen state instead of a set of boolean flags in the `ViewModel`
- **UICollectionView + CompositionalLayout** — flexible and adaptive feed layout
- **DiffableDataSource** — safe animated updates without manual index calculations
- **Background URLSession** — background loading of images and data without third-party libraries
- **Caching** — the cache persists when the app goes to background (disk + memory)
- **Pagination** — paginated loading of news as the user scrolls
- **Dark Mode** — support for light and dark themes
- **Localizable** — string localization via `Localizable.strings`
- **Tinted icon** — icon with tint color support
- **async / await** — all network requests use structured concurrency
- **WKWebView** — opening the full news article on cell tap

## License
This project is distributed under the [MIT](./LICENSE) license.