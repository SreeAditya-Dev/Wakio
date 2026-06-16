# Flutter Complete Developer Guide
> Based on the **Wakio** alarm app (`scan_alarm`) — real examples throughout.

---

## Table of Contents
1. [How Flutter Works on Android & iOS](#1-how-flutter-works-on-android--ios)
2. [Basic Flutter Folder Structure](#2-basic-flutter-folder-structure)
3. [Production Folder Structure (This Project)](#3-production-folder-structure-this-project)
4. [Start Commands & Boilerplate](#4-start-commands--boilerplate)
5. [Key Concepts Every Beginner Must Know](#5-key-concepts-every-beginner-must-know)
6. [Execution Flow — Start to End](#6-execution-flow--start-to-end)
7. [Widgets Explained](#7-widgets-explained)
8. [App Colors & Theme System](#8-app-colors--theme-system)
9. [Production Standards — Play Store & Apple Store](#9-production-standards--play-store--apple-store)
10. [Cache Management in Flutter](#10-cache-management-in-flutter)
11. [Permissions — Complete Guide with Diagrams](#11-permissions--complete-guide-with-diagrams)

---

## 1. How Flutter Works on Android & iOS

Flutter compiles to **native machine code** — it does NOT use a web view or bridge like React Native does.

```
┌─────────────────────────────────────────────────┐
│                  YOUR DART CODE                  │
│              (lib/  — same on both)              │
└──────────────────────┬──────────────────────────┘
                       │ compiled to ARM / x86
         ┌─────────────┼─────────────┐
         ▼                           ▼
  ┌─────────────┐           ┌─────────────────┐
  │   Android   │           │      iOS        │
  │  JVM / ART  │           │  LLVM / Metal   │
  │  (.apk/.aab)│           │  (.ipa)         │
  └──────┬──────┘           └──────┬──────────┘
         │                         │
         ▼                         ▼
  ┌──────────────────────────────────────────┐
  │          Flutter Engine (C++)            │
  │  • Skia/Impeller renderer (draws pixels) │
  │  • Dart runtime                          │
  │  • Platform channels (to native APIs)   │
  └──────────────────────────────────────────┘
         │
         ▼
  ┌──────────────────────────────────────────┐
  │     OS Canvas (Android Surface / iOS     │
  │       Metal layer) — raw pixels only     │
  └──────────────────────────────────────────┘
```

**Key insight:** Flutter owns its own rendering canvas. Android/iOS only give it a surface to paint on. That's why the UI looks **identical** on both platforms — it draws every pixel itself using Skia (old) or Impeller (new).

### Platform differences developers must know

| Area | Android | iOS |
|------|---------|-----|
| Package format | `.apk` (debug) / `.aab` (release) | `.ipa` |
| Store | Google Play | App Store |
| Permissions file | `AndroidManifest.xml` | `Info.plist` |
| Notifications style | Material | Cupertino |
| Background tasks | `WorkManager` / Foreground Service | BGTaskScheduler |
| Build tool | Gradle | Xcode / CocoaPods |
| Min SDK | `minSdkVersion 21` (Android 5) | iOS 12+ typical |

### How platform channels work (for plugins)

```
Dart code  ──► MethodChannel("camera") ──► JNI (Android) / FFI (iOS)
                                             │                │
                                        Camera2 API     AVFoundation
```

Packages like `permission_handler`, `alarm`, `camera` are thin Dart wrappers
that speak across this channel to native platform code.

---

## 2. Basic Flutter Folder Structure

When you run `flutter create my_app`, you get:

```
my_app/
│
├── lib/                    ← ALL your Dart code lives here
│   └── main.dart           ← Entry point — the ONLY required file
│
├── android/                ← Native Android project (Gradle)
│   ├── app/
│   │   └── src/main/
│   │       ├── AndroidManifest.xml   ← permissions, activities
│   │       └── kotlin/...            ← native Kotlin/Java code
│   └── build.gradle.kts
│
├── ios/                    ← Native iOS project (Xcode)
│   ├── Runner/
│   │   ├── Info.plist     ← permissions, app metadata
│   │   └── AppDelegate.swift
│   └── Podfile            ← CocoaPods dependencies
│
├── test/                  ← Unit + widget tests
│   └── widget_test.dart
│
├── assets/                ← Images, fonts, JSON, ML models
│   ├── images/
│   └── models/
│
├── pubspec.yaml           ← The package.json of Flutter
│                            (dependencies, assets, fonts)
└── pubspec.lock           ← Locked versions (commit this)
```

### pubspec.yaml — the most important config file

```yaml
name: my_app
version: 1.0.0+1          # version name + version code

environment:
  sdk: ^3.11.4             # Dart SDK version

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0             # add packages here

flutter:
  assets:
    - assets/images/       # register asset folders
  fonts:
    - family: MyFont
      fonts:
        - asset: assets/fonts/MyFont-Regular.ttf
```

---

## 3. Production Folder Structure (This Project)

The Wakio project uses **feature-first + layer separation**:

```
lib/
│
├── main.dart                        ← App entry point & root widget
│
├── core/                            ← Shared, reusable infrastructure
│   ├── env/
│   │   └── app_env.dart             ← Environment variables (API URLs)
│   │
│   ├── network/
│   │   └── dio_client.dart          ← HTTP client (Dio) setup
│   │
│   ├── router/
│   │   └── app_router.dart          ← All routes defined (go_router)
│   │
│   ├── services/                    ← Business services (alarm, camera, haptics)
│   │   ├── alarm_service.dart
│   │   ├── detection_service.dart
│   │   ├── permissions_service.dart ← ← ← THIS FILE (see Section 11)
│   │   └── ...
│   │
│   ├── storage/                     ← Local persistence
│   │   ├── app_database.dart        ← Drift (SQLite) database
│   │   ├── local_prefs.dart         ← SharedPreferences wrapper
│   │   └── secure_storage.dart      ← flutter_secure_storage (tokens)
│   │
│   ├── theme/                       ← Design tokens
│   │   ├── app_colors.dart          ← Brand palette
│   │   ├── app_theme.dart           ← ThemeData (light + dark)
│   │   └── app_typography.dart      ← Text styles
│   │
│   └── widgets/                     ← Shared UI components
│       ├── app_button.dart
│       ├── app_card.dart
│       └── glass.dart
│
├── data/                            ← Data layer
│   ├── models/                      ← Plain Dart data classes
│   │   ├── alarm_x.dart
│   │   ├── challenge.dart
│   │   └── user.dart
│   │
│   ├── providers/                   ← Riverpod state controllers
│   │   ├── auth_controller.dart
│   │   └── theme_controller.dart
│   │
│   └── repositories/               ← Data access (DB + API)
│       ├── alarm_repository.dart
│       ├── auth_repository.dart
│       └── challenge_repository.dart
│
└── features/                        ← Screen-level feature modules
    ├── auth/
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   └── splash_screen.dart
    ├── home/
    │   ├── home_screen.dart
    │   └── home_shell.dart          ← Bottom nav shell
    ├── alarms/
    ├── scan/
    ├── ring/
    ├── settings/
    └── stats/
```

### Why this structure?

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   features/  │ ──► │    data/     │ ──► │    core/     │
│  (screens)   │     │ (providers,  │     │ (services,   │
│              │     │  repos)      │     │  storage)    │
└──────────────┘     └──────────────┘     └──────────────┘
     UI layer           state layer         infra layer
```

- Features **never** import from other features directly.
- Repositories **never** import screens.
- Core has **no feature knowledge**.

---

## 4. Start Commands & Boilerplate

### Create a new Flutter app

```bash
flutter create my_app          # basic
flutter create --org com.yourcompany my_app   # with package name
cd my_app
flutter run                    # run on connected device / emulator
```

### Essential daily commands

```bash
# Run
flutter run                    # debug mode (hot reload enabled)
flutter run -d chrome          # run as web app
flutter run --release          # release mode (no debug tools)

# Hot reload vs Hot restart
# While running:  r = hot reload (keeps state)
#                 R = hot restart (resets state)
#                 q = quit

# Build
flutter build apk              # Android APK (sideload / debug)
flutter build appbundle        # Android AAB (Play Store upload)
flutter build ipa              # iOS (requires macOS + Xcode)

# Code generation (this project uses it for Riverpod + Drift)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch    # watch mode during development

# Package management
flutter pub get                # install packages from pubspec.yaml
flutter pub upgrade            # upgrade to latest compatible versions
flutter pub outdated           # see which packages have new versions

# Analysis & formatting
flutter analyze                # static analysis
dart format lib/               # auto-format all Dart files
flutter test                   # run all tests

# Doctor
flutter doctor                 # check if your setup is correct
```

### Minimum boilerplate — hello world

```dart
// lib/main.dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello')),
        body: const Center(child: Text('World')),
      ),
    );
  }
}
```

---

## 5. Key Concepts Every Beginner Must Know

### 5.1 Everything is a Widget

In Flutter, **every piece of UI is a widget** — a button, padding, a column, even the app itself.

```
MaterialApp
  └── Scaffold
        ├── AppBar
        │     └── Text("Title")
        └── Column
              ├── Text("Hello")
              └── ElevatedButton
                    └── Text("Press me")
```

### 5.2 StatelessWidget vs StatefulWidget

```dart
// StatelessWidget — no internal state, renders once based on inputs
class MyLabel extends StatelessWidget {
  final String text;
  const MyLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text);
}

// StatefulWidget — has internal state that can change
class Counter extends StatefulWidget {
  const Counter({super.key});
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Count: $_count'),
      ElevatedButton(
        onPressed: () => setState(() => _count++),  // triggers rebuild
        child: const Text('Tap'),
      ),
    ]);
  }
}
```

### 5.3 The Widget Tree, Element Tree, RenderObject Tree

```
Widget Tree          Element Tree         RenderObject Tree
(blueprint)          (instance)           (painting)
──────────           ────────────         ──────────────────
Column               ColumnElement        RenderFlex
 ├── Text("A")        ├── TextElement      ├── RenderParagraph
 └── Text("B")        └── TextElement      └── RenderParagraph
```

- **Widget** = lightweight config blueprint (immutable, cheap to create)
- **Element** = mounts a widget, lives across rebuilds, holds state
- **RenderObject** = does actual layout and painting

### 5.4 BuildContext

`BuildContext` is your location in the widget tree. It lets you:

```dart
// Access theme
final colors = Theme.of(context).colorScheme;

// Navigate
Navigator.of(context).push(...);
context.go('/home');            // go_router shorthand

// Locate inherited widgets
final mediaQuery = MediaQuery.of(context);
```

### 5.5 State Management — Riverpod (this project)

This project uses **Riverpod**, the most popular production state manager.

```dart
// 1. Define a provider
final counterProvider = StateProvider<int>((ref) => 0);

// 2. Read it in a widget (ConsumerWidget = StatelessWidget + ref)
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);  // rebuilds when changed
    return Column(children: [
      Text('$count'),
      ElevatedButton(
        onPressed: () => ref.read(counterProvider.notifier).state++,
        child: const Text('+'),
      ),
    ]);
  }
}
```

### 5.6 async/await — essential for Flutter

All network calls, database reads, and permission checks are async:

```dart
Future<void> loadData() async {
  final result = await api.fetchUser();   // wait without blocking UI
  setState(() => user = result);
}
```

### 5.7 Keys

Keys tell Flutter which widget is which when lists reorder:

```dart
ListView(children: [
  for (final item in items)
    ItemWidget(key: ValueKey(item.id), item: item),  // stable identity
])
```

---

## 6. Execution Flow — Start to End

### Where does execution start?

**`lib/main.dart` → `main()` function.** This is the single entry point for ALL platforms.

```
OS boots your app
       │
       ▼
main() in lib/main.dart          ← EXECUTION STARTS HERE
       │
       ▼
WidgetsFlutterBinding.ensureInitialized()
  (binds Flutter engine to Dart isolate,
   required before any async setup)
       │
       ▼
await alarmService.init()        ← reschedule alarms from DB
       │
       ▼
runApp(WakioApp())               ← hands control to Flutter engine
       │
       ▼
Flutter engine calls WakioApp.build()
       │
       ▼
MaterialApp.router builds
 ├── ThemeData applied (light/dark)
 └── GoRouter picks initial route → /splash
          │
          ▼
       SplashScreen widget builds
          │
          ▼
    (auth check resolves)
          │
     ┌────┴────────┐
     ▼             ▼
  /login        /home (HomeShell → HomeScreen)
```

### Frame-by-frame rendering loop

```
User input / timer / setState()
          │
          ▼
   Flutter schedules rebuild
          │
          ▼
   build() called on changed widgets
          │
          ▼
   Diff vs old widget tree (reconciliation)
          │
          ▼
   Layout pass (RenderObject.layout)
          │
          ▼
   Paint pass (RenderObject.paint → Canvas)
          │
          ▼
   GPU composites layers → screen
   (targets 60fps / 120fps)
```

### Wakio's actual startup sequence (from `main.dart`)

```dart
Future<void> main() async {
  // Step 1: bind engine
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2: create provider container (Riverpod DI)
  final container = ProviderContainer();

  // Step 3: start alarm engine (reads SQLite, reschedules OS alarms)
  await container.read(alarmServiceProvider).init();

  // Step 4: run app (UI appears immediately)
  runApp(UncontrolledProviderScope(container: container, child: WakioApp()));

  // Note: permissions are requested AFTER first frame (in initState)
  // so the user never stares at a blank screen waiting for dialogs
}
```

---

## 7. Widgets Explained

### Structural widgets

```dart
// Layout
Column(children: [...])              // vertical stack
Row(children: [...])                 // horizontal stack
Stack(children: [...])               // overlapping layers
Expanded(child: ...)                 // fills remaining space
Flexible(child: ...)                 // flexible space
SizedBox(width: 100, height: 50)     // fixed size box
Padding(padding: EdgeInsets.all(16), child: ...)
Center(child: ...)
Align(alignment: Alignment.topLeft, child: ...)
Wrap(children: [...])                // wraps to next line

// Scrolling
SingleChildScrollView(child: Column(...))
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, i) => ItemWidget(items[i]),
)
GridView.builder(...)
```

### Display widgets

```dart
Text('Hello', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
Icon(Icons.alarm, size: 32, color: Colors.orange)
Image.asset('assets/images/logo.png')
Image.network('https://...')
CircleAvatar(backgroundImage: NetworkImage(url))
```

### Interactive widgets

```dart
ElevatedButton(onPressed: () {}, child: Text('Click'))
TextButton(onPressed: () {}, child: Text('Cancel'))
IconButton(icon: Icon(Icons.delete), onPressed: () {})
GestureDetector(onTap: () {}, child: ...)
InkWell(onTap: () {}, child: ...)   // with ripple effect
Switch(value: isOn, onChanged: (v) => setState(() => isOn = v))
Slider(value: vol, onChanged: (v) => setState(() => vol = v))
TextField(controller: _controller, decoration: InputDecoration(hintText: 'Email'))
```

### Scaffold — the page template

```dart
Scaffold(
  appBar: AppBar(title: Text('Home'), actions: [IconButton(...)]),
  body: ...,                          // main content
  floatingActionButton: FAB(...),
  bottomNavigationBar: BottomNavigationBar(...),
  drawer: Drawer(...),
)
```

---

## 8. App Colors & Theme System

Flutter's `ThemeData` is the **central app-wide color/style registry**. In this project:

```
AppColors (static constants)
       │
       ▼
AppTheme.light / AppTheme.dark    ← ThemeData objects
       │
       ▼
MaterialApp(theme: AppTheme.light, darkTheme: AppTheme.dark)
       │
       ▼
Any widget: Theme.of(context).colorScheme.primary
            Theme.of(context).extension<AppColorsExt>()!.card
```

### How to use colors in a widget

```dart
// Option 1 — Material color scheme (recommended)
final scheme = Theme.of(context).colorScheme;
Container(color: scheme.surface)
Text('Hi', style: TextStyle(color: scheme.onSurface))

// Option 2 — Custom brand extension (this project)
final ext = Theme.of(context).extension<AppColorsExt>()!;
Container(color: ext.card)

// Option 3 — Direct static constant (avoid in widgets, use for non-UI)
Container(color: AppColors.primary)  // orange — doesn't auto-switch dark/light
```

### Light / dark theme switch

```dart
// In main.dart (Wakio)
MaterialApp.router(
  theme: AppTheme.light,       // used when ThemeMode.light
  darkTheme: AppTheme.dark,    // used when ThemeMode.dark
  themeMode: themeMode,        // ThemeMode.system / .light / .dark
)

// themeMode comes from Riverpod state:
final themeMode = ref.watch(themeControllerProvider);
```

---

## 9. Production Standards — Play Store & Apple Store

### Version naming in pubspec.yaml

```yaml
version: 1.2.3+45
#        │   │ └── versionCode (Android) / CFBundleVersion (iOS) — integer, must always increase
#        └───┘──── versionName (display: "1.2.3")
```

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<manifest ...>
    <!-- Declare ALL permissions you use -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>
    <uses-permission android:name="android.permission.CAMERA"/>

    <application
        android:label="Wakio"
        android:icon="@mipmap/ic_launcher"
        android:requestLegacyExternalStorage="false">

        <!-- Your main activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop">  <!-- prevents duplicate instances -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### iOS — `ios/Runner/Info.plist`

```xml
<dict>
    <!-- Every permission needs a usage description string -->
    <key>NSCameraUsageDescription</key>
    <string>Wakio needs the camera to scan objects to stop your alarm.</string>

    <key>NSUserNotificationUsageDescription</key>
    <string>Wakio sends alarm notifications to wake you up.</string>

    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>          <!-- play alarm sound in background -->
        <string>fetch</string>
    </array>
</dict>
```

### Build for release

```bash
# Android (Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# iOS (App Store) — requires macOS + Xcode + Apple Developer account
flutter build ipa --release
# Then open Xcode → Product → Archive → Distribute App

# Sign Android with a keystore (do this ONCE, keep the keystore safe)
keytool -genkey -v -keystore ~/my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias
```

### android/key.properties (do NOT commit to git)

```properties
storePassword=yourpassword
keyPassword=yourpassword
keyAlias=my-key-alias
storeFile=/Users/you/my-release-key.jks
```

### Production checklist

```
[ ] debugShowCheckedModeBanner: false  in MaterialApp
[ ] Remove all print() calls (use a logger package)
[ ] Enable ProGuard / R8 minification (android/app/build.gradle)
[ ] Set correct package name (com.yourcompany.appname)
[ ] App icon generated (flutter_launcher_icons)
[ ] Splash screen configured
[ ] All permissions declared in AndroidManifest + Info.plist
[ ] Privacy policy URL (required by both stores)
[ ] Set minSdkVersion 21 (Android), iOS deployment target 13+
[ ] Release signing configured
[ ] Test on real device (not just emulator) before submission
[ ] flutter analyze returns 0 issues
[ ] flutter test passes
```

---

## 10. Cache Management in Flutter

"Cache" in Flutter means several things. Here's the full map:

```
┌─────────────────────────────────────────────────────────────────┐
│                    Cache Types in Flutter                        │
│                                                                 │
│  1. HTTP / Network Cache                                        │
│     • Dio (used in this project) can cache responses           │
│     • Use dio_cache_interceptor package                         │
│     • Or cache in local DB (what this project does with Drift) │
│                                                                 │
│  2. Image Cache                                                 │
│     • Flutter has a built-in ImageCache                        │
│     • For network images: cached_network_image package         │
│     • Stores decoded images in RAM (and optionally disk)       │
│                                                                 │
│  3. Local Database (Drift / SQLite)             ← THIS PROJECT │
│     • Persistent, survives app restarts                        │
│     • Full SQL queries                                         │
│     • Used for alarms, history, challenges                     │
│                                                                 │
│  4. SharedPreferences (LocalPrefs)              ← THIS PROJECT │
│     • Key-value store for simple settings                      │
│     • Persists across restarts                                 │
│     • NOT encrypted (don't store tokens here)                  │
│                                                                 │
│  5. Secure Storage (flutter_secure_storage)     ← THIS PROJECT │
│     • Encrypted key-value store                                │
│     • Android: Android Keystore                                │
│     • iOS: Keychain                                            │
│     • Store: JWT tokens, passwords                             │
│                                                                 │
│  6. In-Memory Cache (Riverpod providers)        ← THIS PROJECT │
│     • Lives only while the provider is alive                   │
│     • Cleared on app restart                                   │
│     • Fastest — no I/O                                        │
└─────────────────────────────────────────────────────────────────┘
```

### Decision guide — which cache to use

```
Does the data need to survive app restart?
├── No  → Riverpod provider / in-memory map
└── Yes
    ├── Is it sensitive (token, password)?
    │   └── Yes → flutter_secure_storage
    ├── Is it a simple flag or setting?
    │   └── Yes → SharedPreferences (LocalPrefs)
    └── Is it structured / relational?
        └── Yes → Drift (SQLite)

Is it a network image?
└── Yes → cached_network_image package

Is it an API response you want to serve offline?
└── Yes → Cache in Drift DB (offline-first pattern used here)
```

### How this project caches data

```dart
// lib/core/storage/local_prefs.dart
// SharedPreferences — simple key-value flags
class LocalPrefs {
  final SharedPreferences _prefs;
  Future<bool> get batteryPromptShown =>
      Future.value(_prefs.getBool('battery_prompt_shown') ?? false);
}

// lib/core/storage/secure_storage.dart
// Encrypted — tokens
class SecureStorage {
  final FlutterSecureStorage _store;
  Future<void> saveToken(String token) => _store.write(key: 'jwt', value: token);
  Future<String?> readToken() => _store.read(key: 'jwt');
}

// lib/core/storage/app_database.dart
// Drift SQLite — alarms, history, challenges
// Queried with type-safe Dart DSL, survives app restart + kill
```

### Clear specific caches

```dart
// Clear SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.clear();                           // all keys
await prefs.remove('battery_prompt_shown');    // specific key

// Clear Secure Storage
const storage = FlutterSecureStorage();
await storage.deleteAll();

// Clear image cache
PaintingBinding.instance.imageCache.clear();

// Clear Drift database table
await database.delete(database.alarms).go();
```

---

## 11. Permissions — Complete Guide with Diagrams

### Why permissions exist

Both Android and iOS require apps to **declare and request** access to sensitive hardware and data. If you don't, the feature crashes silently or the app is rejected from the store.

### Permission lifecycle

```
App installed (no permissions granted)
          │
          ▼
App first launch
          │
          ▼
┌─────────────────────────────────────────────────┐
│          DECLARE (build time)                    │
│  Android: AndroidManifest.xml                   │
│  iOS: Info.plist (with usage description)       │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│          CHECK at runtime                        │
│  await Permission.notification.isGranted         │
└─────────────────────┬───────────────────────────┘
                      │
               Already granted?
              ┌───────┴────────┐
              │ Yes            │ No
              ▼                ▼
         Use feature    ┌──────────────────────────┐
                        │  REQUEST                 │
                        │  await p.request()       │
                        │  System dialog appears   │
                        └──────────┬───────────────┘
                                   │
                  ┌────────────────┼───────────────┐
                  ▼                ▼               ▼
             Granted         Denied         Permanently
                │                │            Denied
                ▼                ▼               ▼
           Use feature     Show rationale    openAppSettings()
                           & re-request      (user must go to
                            (once only)      OS settings page)
```

### Permissions used in this project

```
┌────────────────────────────────────────────────────────────────────┐
│  Permission                   │ Why needed            │ Android/iOS│
├───────────────────────────────┼───────────────────────┼────────────┤
│ POST_NOTIFICATIONS            │ Show alarm ring UI    │ Android 13+│
│ SCHEDULE_EXACT_ALARM          │ Fire alarm at exact   │ Android 12 │
│                               │ time (Doze-proof)     │            │
│ REQUEST_IGNORE_BATTERY_OPT.   │ Don't kill alarm in   │ Android    │
│                               │ Doze / power-save     │            │
│ CAMERA                        │ Scan objects to stop  │ Both       │
│                               │ alarm                 │            │
│ NSCameraUsageDescription      │ iOS camera access     │ iOS only   │
│ NSUserNotificationUsage...    │ iOS notifications     │ iOS only   │
└───────────────────────────────┴───────────────────────┴────────────┘
```

### The PermissionsService in this project

```dart
// lib/core/services/permissions_service.dart

class PermissionsService {
  // CHECK — non-destructive, just reads current status
  Future<AlarmPermissions> check() async {
    return AlarmPermissions(
      notifications: await _isGranted(Permission.notification),
      exactAlarm:    await _isGranted(Permission.scheduleExactAlarm),
      batteryUnrestricted: await _isGranted(Permission.ignoreBatteryOptimizations),
    );
  }

  // REQUEST critical ones on every cold start (no-ops if already granted)
  Future<void> ensureCritical() async {
    if (!await _isGranted(Permission.notification))
      await _request(Permission.notification);
    if (!await _isGranted(Permission.scheduleExactAlarm))
      await _request(Permission.scheduleExactAlarm);
  }

  // Battery exemption — asked ONCE only, then never again
  Future<void> requestBatteryExemptionOnce() async {
    if (await _prefs.batteryPromptShown) return;  // already asked
    if (!await _isGranted(Permission.ignoreBatteryOptimizations))
      await _request(Permission.ignoreBatteryOptimizations);
    await _prefs.markBatteryPromptShown();
  }
}
```

### When to request permissions (best practice)

```
❌ BAD — request everything at launch before UI appears
         → User sees a wall of dialogs before they even see the app

✅ GOOD — request just-in-time, with context

  Example:
  User taps "Set Alarm" → request SCHEDULE_EXACT_ALARM
  User opens scan screen → request CAMERA
  After first frame of app → request NOTIFICATION (critical, needs early)
```

### In this project — permissions timing in `main.dart`

```dart
// initState of WakioApp — runs AFTER first frame renders
WidgetsBinding.instance.addPostFrameCallback((_) async {
  await perms.ensureCritical();           // notification + exact alarm
  await perms.requestBatteryExemptionOnce(); // once-only battery prompt
});
// Result: user sees the splash screen first, THEN the permission dialogs
```

### Permission states

```dart
PermissionStatus.granted          // user said yes
PermissionStatus.denied           // user said no (can re-request)
PermissionStatus.permanentlyDenied // user said "never ask again"
                                   // must use openAppSettings()
PermissionStatus.restricted       // iOS: parental controls block it
PermissionStatus.limited          // iOS: partial access (photo library)
```

### Complete permission handling pattern

```dart
Future<void> handleCameraPermission(BuildContext context) async {
  final status = await Permission.camera.status;

  if (status.isGranted) {
    // Already granted — go ahead
    openCamera();
    return;
  }

  if (status.isDenied) {
    // Ask for it
    final result = await Permission.camera.request();
    if (result.isGranted) {
      openCamera();
    } else {
      // Show why it matters
      showSnackBar(context, 'Camera is needed to scan objects');
    }
    return;
  }

  if (status.isPermanentlyDenied) {
    // Can't ask in-app anymore — send user to settings
    final opened = await openAppSettings();
    if (!opened) {
      showSnackBar(context, 'Please enable Camera in System Settings');
    }
  }
}
```

### AndroidManifest.xml permission declarations (this project)

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
    <!-- Network -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <!-- Alarm (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <!-- Android 12 only — auto granted via USE_EXACT_ALARM on 13+ -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <!-- Android 13+ -->
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

    <!-- Battery — lets alarm ring even in Doze mode -->
    <uses-permission
        android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>

    <!-- Camera — scan to stop alarm -->
    <uses-permission android:name="android.permission.CAMERA"/>

    <!-- Foreground service for the ringing alarm -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission
        android:name="android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE"/>
</manifest>
```

### iOS Info.plist permission declarations

```xml
<!-- ios/Runner/Info.plist -->
<dict>
    <key>NSCameraUsageDescription</key>
    <string>Wakio needs your camera to scan an object and stop your alarm.</string>

    <key>NSUserNotificationUsageDescription</key>
    <string>Wakio needs to show alarm notifications even when the app is closed.</string>

    <!-- Background audio — so the alarm sound plays when screen is locked -->
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
        <string>fetch</string>
        <string>remote-notification</string>
    </array>
</dict>
```

### Permission flow diagram — Wakio alarm sequence

```
App cold start
     │
     ▼
main() → alarmService.init()
     │
     ▼
runApp() → splash screen visible (user sees UI immediately)
     │
     ▼ (first frame callback — 16ms after UI appears)
ensureCritical()
     ├── Check: notifications granted?
     │     No → System dialog: "Allow Wakio to send notifications?"
     │           ├── Allow → proceed
     │           └── Don't allow → alarm won't show full-screen UI
     │
     └── Check: scheduleExactAlarm granted?
           No → System dialog: "Allow exact alarms?"
                ├── Allow → alarm fires at exact scheduled time
                └── Deny  → alarm may be delayed by OS
     │
     ▼
requestBatteryExemptionOnce()   (only if not shown before)
     └── System dialog: "Allow Wakio to run in background?"
           ├── Allow → alarm works even in Doze / battery save mode
           └── Deny  → alarm may be killed by OS in power-save mode
     │
     ▼
App is fully operational
User sets alarm → SchedExactAlarm fires → ring screen appears
```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│  Flutter Quick Reference                                     │
├─────────────────────────────────────────────────────────────┤
│  Entry point:    lib/main.dart → main()                     │
│  Run:            flutter run                                 │
│  Build Android:  flutter build appbundle --release          │
│  Build iOS:      flutter build ipa --release                │
│  Hot reload:     r (while running)                          │
│  Hot restart:    R (while running)                          │
│  Dependencies:   pubspec.yaml + flutter pub get             │
│  Code gen:       dart run build_runner build                │
│  Theme:          Theme.of(context).colorScheme              │
│  Navigate:       context.go('/route')  (go_router)          │
│  State:          ref.watch(provider)   (riverpod)           │
│  Permissions:    permission_handler package                  │
│  Local storage:  drift (SQL) / shared_preferences / secure  │
└─────────────────────────────────────────────────────────────┘
```
