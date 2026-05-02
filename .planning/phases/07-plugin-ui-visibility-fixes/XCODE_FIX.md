# Xcode Build Fix - Phase 7

## 🚨 Aktuelles Problem

Xcode zeigt beim Build folgende Fehler:
```
Error: the bundle being updated at NSBundle ... has no CFBundleIdentifier!
Fatal updater error (6): Sparkle cannot target a bundle that does not have a valid bundle identifier for Debug.
Cannot index window tabs due to missing main bundle identifier
```

**Ursache:**
- Das Projekt ist ein **Swift Package** (Package.swift)
- Xcode generiert ein **temporäres Projekt** beim Öffnen
- Das temporäre Projekt hat **keine Bundle-Identifier** in den Build Settings
- macOS GUI Apps benötigen ein **.app-Bundle** mit gültiger Info.plist

---

## ✅ Schon implementierte Lösungen

### 1. Info.plist aktualisiert
**Datei:** `Ollamac/Resources/Info.plist`

Hinzugefügt:
```xml
<key>CFBundleIdentifier</key>
<string>com.kevinhermawan.Ollamac</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
<key>CFBundleShortVersionString</key>
<string>3.0.3</string>
```

### 2. Sparkle in Debug-Modus deaktiviert
**Datei:** `Ollamac/App/OllamacApp.swift`

```swift
#if DEBUG
let updaterController = SPUStandardUpdaterController(startingUpdater: false, ...)
#else
let updaterController = SPUStandardUpdaterController(startingUpdater: true, ...)
#endif
```

**Wirkung:** Sparkle versucht in Debug nicht, Bundle-Informationen zu lesen.

---

## 🔧 Manuelle Schritte für Xcode

### Schritt 1: Xcode komplett schließen
- Beende Xcode vollständig

### Schritt 2: DerivedData löschen
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Ollamac-*
```

### Schritt 3: Xcode mit Package.swift öffnen
- Xcode starten
- **File > Open...**
- **Package.swift** auswählen (nicht Ollamac.xcodeproj!)
- Auf "Open" klicken

### Schritt 4: Warten bis Projekt geladen ist
- Xcode generiert temporäres Projekt
- Alle Dateien werden angezeigt

### Schritt 5: Build Settings für Target "Ollamac" anpassen

**So kommst du zu den Build Settings:**
1. Im **Project Navigator** (links) auf **Ollamac** klicken (oberste Ebene, nicht der Ordner!)
2. Das **Target "Ollamac"** auswählen (unter "Targets")
3. Tab **"Build Settings"** öffnen
4. Im Suchfeld oben die folgenden Einstellungen suchen und setzen:

| Einstellung | Wert | Suchbegriff |
|-------------|------|-------------|
| Product Bundle Identifier | `com.kevinhermawan.Ollamac` | PRODUCT_BUNDLE |
| Bundle version | `1.0.0` | CFBundleVersion |
| Bundle versions string, short | `3.0.3` | CFBundleShortVersionString |
| Info.plist File | `Ollamac/Resources/Info.plist` | INFOPLIST_FILE |
| Executable Name | `Ollamac` | PRODUCT_NAME |
| Wrapper Extension | `app` | WRAPPER_EXTENSION |

**Wichtig:**
- Die Einstellungen sind **pro Target**, nicht pro Projekt
- Achte darauf, dass du das **Ollamac-Target** ausgewält hast
- Drücke **Enter** nach jeder Änderung, damit sie gespeichert wird

### Schritt 6: Clean Build durchführen
- **Product > Clean Build Folder** (⌘⇧K)
- Oder **Product > Clean** (⌘⇧C)

### Schritt 7: App bauen und ausführen
- **⌘B** (Build)
- **⌘R** (Run)

---

## 🎯 Verifikation

Nach erfolgreicher Konfiguration:
- ✅ Keine Bundle-Identifier-Fehler mehr
- ✅ Keine Sparkle-Fehler in Debug
- ✅ App startet und Fenster wird angezeigt
- ✅ Einstellungen (⌘+) zeigt 3 Tabs: General, **Plugins**, Experimental
- ✅ Plugins-Tab zeigt Ollama und MCP an

---

## 📋 Alternative: Terminal Build

Falls Xcode immer noch Probleme macht, kannst du die App im Terminal bauen und ausführen:

```bash
# 1. App bauen (Release-Modus)
cd /Users/anierbeck/git/Ollamac
swift build -c release

# 2. App ausführen
open .build/arm64-apple-macosx/release/Ollamac
```

**Hinweis:**
- Die App startet ohne Xcode Debugger
- Sparkle ist im Release-Modus aktiv (aber mit korrekten Bundle-Settings)
- Alle Phase 7 Änderungen sind enthalten

---

## 🔍 Fehlerbehebung

### Problem: "Cannot index window tabs"
- **Ursache:** App läuft als Executable ohne Bundle
- **Lösung:** Wrapper Extension = "app" setzen (Schritt 5)

### Problem: "Sparkle cannot target a bundle"
- **Ursache:** Sparkle sucht Bundle Identifier für Update-Check
- **Lösung:** Product Bundle Identifier setzen (Schritt 5) + Sparkle ist bereits in Debug deaktiviert

### Problem: "has no CFBundleIdentifier"
- **Ursache:** Bundle Identifier fehlt in Build Settings
- **Lösung:** Product Bundle Identifier setzen (Schritt 5)

### Problem: Module Dependencies nicht gefunden
- **Ursache:** Xcode temporäres Projekt hat keine Dependencies
- **Lösung:** **NICHT "Open Project" verwenden, sondern "Open Package.swift"**
- Wenn du das .xcodeproj öffnest, funktionieren die Dependencies nicht

---

## ⚠️ Wichtig

### ✅ Richtig:
- **File > Open > Package.swift** (Swift Package Modus)
- Build Settings im **Target "Ollamac"** setzen

### ❌ Falsch:
- **File > Open > Ollamac.xcodeproj** (Xcode Projekt Modus)
- Build Settings im **Projekt** (nicht Target) setzen

---

## 📞 Kontakt

Falls weitere Hilfe benötigt wird, bitte:
1. Genauen Fehlertext kopieren
2. Schritte, die bereits versucht wurden, auflisten
3. Xcode-Version angeben (Xcode > About Xcode)

---

*Erstellt: 2025-05-02*
*Phase: 7 - Plugin UI Visibility Fixes*
*Aktualisiert: Xcode Build Fix für Swift Package*
