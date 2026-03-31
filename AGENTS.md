# Pessoa Pensadora — Flutter App Specification

## 1. Project Overview

A mobile reading app for Fernando Pessoa's heteronyms. The new design introduces a bottom navigation shell, grouped saved texts, and a dark B&W theme. All new screens and state management must follow the existing project's conventions.

**Target:** Android + iOS + Web (already supported by the existing project).

---

## 2. Tech Stack

Match the existing `pubspec.yaml` exactly. Do **not** introduce Riverpod or go_router.

| Concern                   | Package (existing)                                      |
| ------------------------- | ------------------------------------------------------- |
| State management          | `get: ^4.6.5` (GetX)                                    |
| Navigation                | GetX named routes (`Get.toNamed`, `GetMaterialApp`)     |
| Fonts                     | `google_fonts: ^8.0.1`                                  |
| Persistence (user state)  | `hive: ^2.2.3` + `hive_flutter: ^1.1.0`                 |
| Persistence (preferences) | `shared_preferences: ^2.0.7`                            |
| HTTP                      | `http: ^1.2.1` (fetches from arquivopessoa.net)         |
| HTML parsing              | `html: ^0.15.0`                                         |
| Serialization             | `json_serializable: ^6.1.4` + `json_annotation: ^4.8.1` |
| Value equality            | `equatable: ^2.0.3`                                     |
| Logging                   | `logger: ^2.2.0` (via `logger_factory.dart`)            |
| Loading spinners          | `flutter_spinkit: ^5.1.0`                               |
| Code gen                  | `build_runner`                                          |

---

## 3. Project Structure

Follow the existing layer layout. New files are placed alongside existing counterparts.

```
lib/
├── main.dart                             # Hive init, adapter registration (unchanged)
│
├── dto/box/
│   ├── box_person_category.dart          # Existing Hive DTO
│   └── box_person_text.dart              # Existing Hive DTO
│
├── model/
│   ├── pessoa_category.dart              # Existing domain model (int id)
│   ├── pessoa_text.dart                  # Existing domain model (int id)
│   └── saved_text.dart                   # Existing Hive model
│
├── repository/
│   ├── read_store.dart                   # Existing — Hive Box<bool> keyed by text id (int)
│   ├── saved_store.dart                  # Existing — Hive Box<SavedText>
│   ├── history_store.dart                # Existing
│   ├── collapsable_store.dart            # Existing
│   └── reader_preference_store.dart      # Existing
│
├── service/
│   ├── text_store.dart                   # Existing GetxController (fetches + caches)
│   ├── selection_action_service.dart     # Existing
│   ├── read_controller.dart              # NEW — thin GetxController wrapping ReadRepository
│   └── saved_controller.dart             # NEW — thin GetxController wrapping SavedRepository
│
├── util/
│   ├── action_feedback.dart              # Existing
│   ├── generic_extensions.dart           # Existing
│   ├── logger_factory.dart               # Existing
│   ├── string_utils.dart                 # Existing — add timeFmt() here
│   └── widget_extensions.dart            # Existing
│
└── ui/
    ├── bonito_theme.dart                 # Existing — extend with B&W color constants
    ├── routes.dart                       # Existing — add searchScreen constant
    │
    ├── screen/
    │   ├── base_screen.dart              # Existing — add new GetPage registrations
    │   ├── boot_screen.dart              # Existing — register new controllers here
    │   ├── splash_screen.dart            # Existing
    │   ├── home_screen.dart              # Existing — add bottomNavigationBar + IndexedStack
    │   ├── saved_texts_screen.dart       # Existing — adapt to grouped layout
    │   ├── saved_text_reader_screen.dart # Existing — reuse for reading
    │   ├── history_screen.dart           # Existing — adapt list layout
    │   └── search_screen.dart            # NEW
    │
    └── widget/
        ├── navigation_widget.dart                  # Existing
        ├── text_selection_drawer.dart               # Existing
        ├── text_selection_drawer_list_view.dart     # Existing
        ├── button/                                  # Existing
        ├── reader/                                  # Existing
        ├── bottom_nav_widget.dart                   # NEW
        ├── het_card_widget.dart                     # NEW: heteronym card
        ├── coll_item_widget.dart                    # NEW: collection row
        ├── text_row_widget.dart                     # NEW: text list row with read/save
        ├── s_item_widget.dart                       # NEW: saved/history list row
        ├── group_header_widget.dart                 # NEW: uppercase section label
        └── highlight_text_widget.dart               # NEW: RichText with query matches
```

---

## 4. Data Models

### Existing models — do not change

**`lib/model/pessoa_category.dart`** — `PessoaCategory` with `id` (int), `name`, `parent`, child categories, and texts. Generated via `json_serializable`.

**`lib/model/pessoa_text.dart`** — `PessoaText` with `id` (int), `title`, `body` (HTML string from arquivopessoa.net), `categoryId`. Generated via `json_serializable`.

**`lib/model/saved_text.dart`** — `SavedText` with a Hive `TypeAdapter`.

### Adaptation note

The existing models use **integer IDs** (from the arquivopessoa.net API). All ID comparisons in new code must use `int`, consistent with `ReadRepository` (`Box<bool>` keyed by `int`) and `SavedRepository`.

---

## 5. State / Controllers

All state lives in **GetX controllers** registered with `Get.put()` in `boot_screen.dart`. Do not use Riverpod, `ChangeNotifier`, or `setState` for shared state.

### Existing controllers

| Class                   | Type             | Responsibility                                                    |
| ----------------------- | ---------------- | ----------------------------------------------------------------- |
| `TextStore`             | `GetxController` | Fetches categories + texts from arquivopessoa.net; caches in Hive |
| `ReadRepository`        | plain class      | `Hive.openBox('readTexts')` — `Box<bool>`, key = text id (int)    |
| `SavedRepository`       | plain class      | `Hive.openBox('savedTexts')` — `Box<SavedText>`                   |
| `HistoryRepository`     | plain class      | Recently read text IDs + timestamps                               |
| `ReaderPreferenceStore` | plain class      | Persists reader mode                                              |
| `CollapsableStore`      | plain class      | Persists expanded category tree nodes                             |

### New controllers (add to `lib/service/`)

Wrap the Hive repositories in thin `GetxController`s so the UI can react via `Obx()`:

```dart
// lib/service/read_controller.dart
class ReadController extends GetxController {
  final ReadRepository _repo;
  ReadController(this._repo);

  final readIds = <int>{}.obs;   // RxSet<int>

  @override
  void onInit() {
    super.onInit();
    readIds.addAll(_repo.getAllReadIds());
  }

  Future<void> toggle(int id) async {
    await _repo.toggleRead(id);
    readIds.contains(id) ? readIds.remove(id) : readIds.add(id);
  }

  bool isRead(int id) => readIds.contains(id);
}

// lib/service/saved_controller.dart — analogous pattern
```

Register in `boot_screen.dart` after existing init:

```dart
Get.put(ReadController(readRepo));
Get.put(SavedController(savedRepo));
```

Consume in widgets:

```dart
final readCtrl = Get.find<ReadController>();
Obx(() => Icon(readCtrl.isRead(text.id) ? Icons.check : Icons.circle_outlined))
```

---

## 6. Routing (`lib/ui/routes.dart`)

Add to the existing `Routes` class — do not replace it.

```dart
class Routes {
  // Existing
  static const bootScreen     = "/boot";
  static const homeScreen     = "/home";
  static const savedScreen    = "/saved";
  static const readTextScreen = "/textReader";
  static const historyScreen  = "/history";

  // New
  static const searchScreen   = "/search";
}
```

Register the new `GetPage` in `base_screen.dart` alongside existing ones. Navigation:

- `Get.toNamed(Routes.readTextScreen, arguments: text)` — push (back stack grows)
- `Get.back()` — pop
- Tab switches: mutate `currentTab` RxInt directly (no route change)
- `Get.toNamed(Routes.searchScreen, parameters: {'q': query})` — push search

---

## 7. Theme (`lib/ui/bonito_theme.dart`)

Extend the existing `bonito_theme.dart` — add B&W constants without removing existing ones.

```dart
// Add to existing bonito_theme.dart:
static const bgDeep      = Color(0xFF000000);
static const bgPrimary   = Color(0xFF080808);
static const bgSecondary = Color(0xFF111111);
static const bgElevated  = Color(0xFF1A1A1A);
static const bgHover     = Color(0xFF212121);
static const borderCol   = Color(0xFF1D1D1D);
static const borderMid   = Color(0xFF2E2E2E);
static const gold        = Color(0xFFD4D4D4);
static const goldDim     = Color(0xFF686868);
static const goldBright  = Color(0xFFFFFFFF);
static const textPrimary = Color(0xFFEEEEEE);
static const textDim     = Color(0xFFAAAAAA);
static const textMuted   = Color(0xFF505050);
static const greenTone   = Color(0xFF909090);

// Fonts:
// Body/reader text: GoogleFonts.lora()
// All UI chrome:    GoogleFonts.inter()
```

Apply to `GetMaterialApp` in `base_screen.dart`:

```dart
ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: BonitoTheme.bgPrimary,
  appBarTheme: AppBarTheme(backgroundColor: BonitoTheme.bgSecondary, elevation: 0),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: BonitoTheme.bgSecondary,
    selectedItemColor: BonitoTheme.gold,
    unselectedItemColor: BonitoTheme.textMuted,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
)
```

---

## 8. Screen Layouts

### 8.1 Home Screen — Bottom Nav Shell (`home_screen.dart`)

Modify the existing `HomeScreen` to add a `bottomNavigationBar`. The side drawer can remain as a secondary entry point or be removed in favour of the in-body browse tab.

```
┌──────────────────────────────────┐
│  AppBar                          │  height: 50
│  [Logo "Pessoa"] | [SearchField] │
├──────────────────────────────────┤
│  IndexedStack (3 tabs)           │  flex: 1
│  [0] Browse  [1] Guardados  [2] Histórico
├──────────────────────────────────┤
│  BottomNavigationBar             │  height: 58 + SafeArea
│  [◉ Explorar] [♡ Guardados] [◔ Histórico]
└──────────────────────────────────┘
```

```dart
final currentTab = 0.obs;

bottomNavigationBar: SafeArea(
  child: Obx(() => BottomNavWidget(
    currentIndex: currentTab.value,
    onTap: (i) => currentTab.value = i,
  )),
),
body: Obx(() => IndexedStack(
  index: currentTab.value,
  children: [BrowseTab(), SavedTextsScreen(), HistoryScreen()],
)),
```

Search `TextField` in AppBar calls `Get.toNamed(Routes.searchScreen, parameters: {'q': query})` on submit.

### 8.2 Browse Tab — Root View (heteronym cards)

```
┌──────────────────────────────────┐
│  "A Obra de Fernando Pessoa"     │
│  "Cinco hetónimos · Uma vida…"   │
├──────────────────────────────────┤
│  ┌────────────────────────────┐  │
│  │ Alberto Caeiro             │  │
│  │ Mestre dos Hetónimos       │  │
│  │ Pensa com sensações        │  │
│  │ 3 colecções · 5/9 lidos    │  │
│  └────────────────────────────┘  │
│  (repeat per top-level category) │
└──────────────────────────────────┘
```

- `Obx(() => ...)` wrapping `TextStore.categories` observable
- `FlutterSpinkit` while loading
- Top-level categories: `mainCategories` IDs (26=Caeiro, 23=Campos, 25=Reis, 27=Pessoa, 33=Desassossego, 24=Mensagem)
- Read count via `ReadController.readIds`
- Tap card → push category content

### 8.3 Category — Collection List

```
┌──────────────────────────────────┐
│ Breadcrumb: Biblioteca › Caeiro  │
│ Alberto Caeiro                   │
│ [filter input]                   │
├──────────────────────────────────┤
│  O Guardador de Rebanhos         │
│  1914 · 3/5 lidos      5 textos  │
└──────────────────────────────────┘
```

- Filter uses a local `RxString` + `Obx()` — no separate controller needed
- Data from child categories of the selected `PessoaCategory` via `TextStore`

### 8.4 Texts List

```
┌──────────────────────────────────┐
│ Breadcrumb + FilterBar           │
├──────────────────────────────────┤
│  ● 01  Título do Poema           │
│        subtítulo            [○ read] [♡ save]
│  ─────────────────────────────── │
│  ○ 02  …                         │
└──────────────────────────────────┘
```

- Green dot when `ReadController.isRead(text.id)`; save icon from `SavedController.isSaved(text.id)`
- Both buttons call the respective controller `.toggle(id)`; `Obx()` rebuilds reactively
- Tap row → `Get.toNamed(Routes.readTextScreen, arguments: text)``

### 8.5 Reader Screen (`saved_text_reader_screen.dart` re-used)

```
┌──────────────────────────────────┐
│ AppBar: [← back] [breadcrumb]    │
├──────────────────────────────────┤
│  (scrollable body)               │
│                                  │
│   ALBERTO CAEIRO  (small caps)   │
│   Title of the Poem              │
│   Subtitle                       │
│   ──────  (gold hairline)        │
│   [○ Marcar como Lido] [♡ Guardar]│
│                                  │
│   Poem stanza line 1             │
│   Poem stanza line 2             │
│                                  │
│   Next stanza…                   │
│                                  │
│ ──────────────────────────────── │
│  [← Anterior]  1 de 5  [Seg. →] │
└──────────────────────────────────┘
```

- `body` field of `PessoaText` is HTML — use the existing `html` package + existing `TextReader` widget in `lib/ui/widget/reader/`
- Body text style: `GoogleFonts.lora(fontSize: 17, height: 1.95)`
- Action buttons use `Obx()` watching `ReadController` / `SavedController`
- Prev/Next: receive sibling texts list as argument, navigate with `Get.offNamed(Routes.readTextScreen, arguments: nextText)`
- Scroll reset: `scrollController.jumpTo(0)` on init or when text changes

### 8.6 Saved View

```
┌──────────────────────────────────┐
│  ch-title: Guardados             │
├──────────────────────────────────┤
│  ALBERTO CAEIRO  (group header)  │
│  ┌──────────────────────────┐    │
│  │ Título  · O Guard. Reb.  │[✕] │
│  └──────────────────────────┘    │
│  BERNARDO SOARES                 │
│  │ Fragmento I · LD Vol. I  │[✕] │
└──────────────────────────────────┘
```

- `Obx()` watches `SavedController.savedIds`
- Group by parent `PessoaCategory` in `mainCategories` order
- `GroupHeaderWidget` before each non-empty group
- `✕` calls `SavedController.toggle(id)`
- Tap → `Get.toNamed(Routes.readTextScreen, arguments: text)`

### 8.7 History View

Same visual structure as Saved, ungrouped, chronological newest-first, with `timeFmt(ts)` at row right instead of `✕`.

### 8.8 Search Screen (`search_screen.dart` — new)

```
┌──────────────────────────────────┐
│  3 resultados encontrados        │
│  "palavra pesquisada"            │
├──────────────────────────────────┤
│  CAEIRO · O Guard. Rebanhos       │
│  Title with highlight            │
│  ...snippet with highlight...    │
│  (repeat)                        │
└──────────────────────────────────┘
```

- Receives query via `Get.parameters['q']`
- Searches `TextStore`'s in-memory loaded texts synchronously
- `HighlightTextWidget`: `RichText` with `TextSpan`s — normal / `color: goldBright, fontWeight: bold` for matches
- Tap → `Get.toNamed(Routes.readTextScreen, arguments: text)`

---

## 9. Widgets Inventory

| Widget                        | File                                | Notes                                    |
| ----------------------------- | ----------------------------------- | ---------------------------------------- |
| `BottomNavWidget`             | `widget/bottom_nav_widget.dart`     | Stateless; `currentIndex` + `onTap`      |
| `HetCardWidget`               | `widget/het_card_widget.dart`       | Tappable card with `Obx` read count      |
| `CollItemWidget`              | `widget/coll_item_widget.dart`      | Collection row with count chip           |
| `TextRowWidget`               | `widget/text_row_widget.dart`       | `Obx` read dot + save icon               |
| `SItemWidget`                 | `widget/s_item_widget.dart`         | Saved/history row                        |
| `GroupHeaderWidget`           | `widget/group_header_widget.dart`   | Uppercase, `textMuted`, `bgSecondary` bg |
| `HighlightTextWidget`         | `widget/highlight_text_widget.dart` | `RichText` with regex match spans        |
| (existing) `TextReader`       | `widget/reader/text_reader.dart`    | HTML reader — reuse as-is                |
| (existing) `NavigationWidget` | `widget/navigation_widget.dart`     | Reuse or extend for breadcrumbs          |

---

## 10. Navigation Logic

```
Boot → Splash → HomeScreen (tab 0: Browse)

Browse tab (tab 0):
  Root cards → Category list → Texts list → ReadTextScreen
                                                 └─ Get.back() → Texts list

Saved tab (tab 1):
  SavedTextsScreen → ReadTextScreen → Get.back() → SavedTextsScreen

History tab (tab 2): same pattern

AppBar search TextField:
  Get.toNamed(Routes.searchScreen) → SearchScreen → ReadTextScreen
```

- Tab switching: mutate `currentTab.obs` directly — no route push, `IndexedStack` preserves scroll
- `ReadTextScreen` always reached via `Get.toNamed` (push), so `Get.back()` works correctly
- Prev/Next in reader: use `Get.offNamed` (replace, no back-stack growth)

---

## 11. Persistence Layer

No changes to existing repository classes or Hive box names.

| Repository              | Box name             | Value type  | Key type          |
| ----------------------- | -------------------- | ----------- | ----------------- |
| `ReadRepository`        | `'readTexts'`        | `bool`      | `int` (text id)   |
| `SavedRepository`       | `'savedTexts'`       | `SavedText` | auto              |
| `HistoryRepository`     | existing box         | DTO         | auto              |
| `CollapsableStore`      | existing box         | `bool`      | category id (int) |
| `ReaderPreferenceStore` | `shared_preferences` | primitives  | string keys       |

---

## 12. Key Implementation Notes for the AI Agent

1. **GetX, not Riverpod** — All reactive state uses `.obs` variables and `Obx()`. Controllers registered with `Get.put()`. No `ConsumerWidget`, no `ref`.

2. **Hive IDs are ints** — `PessoaText.id` and `PessoaCategory.id` are `int`. All read/saved lookups use `int` keys.

3. **HTML body parsing** — `PessoaText.body` is an HTML string. Use the existing `html` package + the existing `TextReader` widget in `lib/ui/widget/reader/`.

4. **Boot sequence is fixed** — Do not move initialization out of `boot_screen.dart`. Register new controllers there after their repositories are ready.

5. **`IndexedStack` for tabs** — Preserves scroll positions. Wrap the stack and `BottomNavigationBar` in `Obx()` watching `currentTab`.

6. **Safe area** — Wrap `BottomNavigationBar` in `SafeArea`. The existing project already handles Android 15 edge-to-edge in `android/`.

7. **`logger_factory.dart`** — Use `log.d()`, `log.i()`, `log.e()`. Never use `print()`.

8. **`flutter_spinkit`** — Use for loading states while `TextStore` is fetching. Follow the pattern in existing screens.

9. **`equatable`** — New model classes must extend `Equatable` and override `props`. `EquatableConfig.stringify = true` is set in `main.dart`.

10. **`build_runner`** — Run `dart run build_runner build` after any `@JsonSerializable` or `@HiveType` changes. Do not hand-write `.g.dart` files.

11. **`timeFmt()` helper** — Add to `lib/util/string_utils.dart`:

    ```dart
    String timeFmt(int ts) {
      final d = DateTime.now().millisecondsSinceEpoch - ts;
      if (d < 60000)       return 'agora mesmo';
      if (d < 3600000)     return 'há ${d ~/ 60000}min';
      if (d < 86400000)    return 'há ${d ~/ 3600000}h';
      return 'há ${d ~/ 86400000}d';
    }
    ```

12. **Group-by for Saved** — Iterate `mainCategories` order from `TextStore`, filter against `SavedController.savedIds`, emit a `GroupHeaderWidget` before each non-empty group.
