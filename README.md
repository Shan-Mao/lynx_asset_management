# Lynx Asset Management

> [简体中文](README_zh.md)

A cross-platform personal asset management tool built with Flutter. Track your purchases and calculate **daily average cost** at a glance.

## Features

### Core
- **Daily Average Cost**: automatically calculated as `(price + additionalCost) / days since purchase`, colour-coded by cost level
- **Asset CRUD**: add, edit, delete assets with fields for price, additional cost, purchase date, category, tags, additional items, notes
- **Asset Status**: mark assets as retired, sold, excluded from total, excluded from daily cost; set expiry dates
- **Summary Dashboard**: gradient header showing total asset count, total value, and aggregate daily cost

### Interface
- **List / Grid Layout**: switch between list and compact grid modes; configure grid aspect ratio (V:V / V:H / H:H) and column counts for portrait and landscape
- **Theme**: light, dark, system-follow, AMOLED black, dynamic colour (Material You), custom seed colour with RGB/HSV/HSL sliders
- **Language**: Chinese / English, language-file-based i18n (add new languages by creating a single map file)

### Data Management
- **TXT Export**: fully configurable — custom file naming template with `{export_date}` and `{user_name}` tokens, selectable field separator, per-field export toggles
- **TXT Import**: parse exported files to restore or migrate data
- **Persistent Storage**: JSON file storage on Android via `path_provider`; in-memory ephemeral mode on Web
- **Export Format Settings**: dedicated configuration page for encoding, field separator, and export field selection, grouped under an expandable "Content Rules" section

### Profile & Customisation
- **Custom Display Name**: tap to edit, used in file exports
- **Custom Avatar**: choose from 16 preset icons or pick a photo from gallery, with built-in interactive 1:1 square crop editor

### Platform
- **Android**: persistent local JSON storage, native file save/share
- **Web**: GitHub Pages static deployment, ephemeral in-memory data, share-based export

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Flutter 3.44 / Dart 3.12 |
| State | Provider + ChangeNotifier |
| Persistence | Abstract `StorageService` (Mobile → JSON file, Web → in-memory) |
| Export Format | Custom structured TXT (`===ASSET===` / `===END===` blocks) |
| Theming | Material 3, `ColorScheme.fromSeed()` |
| i18n | Static map-based (`lib/lang/{locale}.dart`) |

## Getting Started

```bash
# Run on Android emulator / device
flutter run

# Run in Chrome (web)
flutter run -d chrome

# Build for GitHub Pages
flutter build web --base-href /lynx_asset_management/
```

## Project Structure

```
lib/
├── main.dart                      # Entry point, MultiProvider setup
├── app.dart                       # MaterialApp, theme, locale wiring
├── lang/                          # i18n: zh.dart, en.dart
├── models/                        # AssetItem data model
├── providers/                     # ChangeNotifier providers
│   ├── asset_provider.dart        # Asset CRUD + persistence
│   ├── theme_provider.dart        # Theme mode, colours
│   ├── locale_provider.dart       # Language switching
│   ├── layout_provider.dart       # List/grid layout settings
│   ├── profile_provider.dart      # Display name, avatar
│   └── save_format_provider.dart  # Export format configuration
├── screens/                       # All screens
│   ├── home_screen.dart           # Asset list + summary + FAB
│   ├── add_edit_asset_screen.dart # Add/edit form
│   ├── asset_detail_screen.dart   # Asset detail view
│   ├── profile_screen.dart        # Profile, settings entry
│   ├── settings_screen.dart       # Data, theme, language, layout
│   ├── personalization_screen.dart # Device type, save format, preview
│   ├── save_format_screen.dart    # Naming, content rules, preview
│   ├── theme_screen.dart          # Theme mode tabs
│   ├── seed_color_screen.dart     # Colour presets + RGB/HSV/HSL
│   ├── about_screen.dart          # App description
│   ├── image_editor_screen.dart   # Interactive 1:1 crop editor
│   └── shell_screen.dart          # Bottom NavigationBar host
├── services/                      # Storage abstraction + export/import
├── utils/                         # Formatters, i18n wrapper, constants
└── widgets/                       # Reusable widgets
    ├── asset_card.dart            # List card
    ├── grid_asset_card.dart       # Grid card
    ├── daily_cost_chip.dart       # Cost indicator chip
    ├── summary_header.dart        # Statistics header
    └── empty_state.dart           # Empty list placeholder
```

