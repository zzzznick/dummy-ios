# East Garden

East Garden is an **English-only** tabletop reference utility for exploring winds, honor tiles, and improvised fourteen-tile sketches. It behaves like a hybrid **tool + casual study companion**: everything works offline in `shared_preferences`; nothing requires a live backend for hands or settings.

**Primary surfaces (excluding Settings):**

1. **Winds** — explanatory cards for compass seats and optional seat ribbon context.
2. **Honors** — chip glossary for winds and dragons with concise blurbs.
3. **Sketch** — staged tile palette (characters, dots, bamboo, honors) capped at fourteen tiles, with save-to-library.
4. **Library** — saved sketches with delete, open-in-editor, and reorder by recency.
5. **Bloom** — calm ring timed from Courtyard settings between study passes.

**Courtyard (Settings)** ships from the app-bar nature icon: felt-wash color chips, honor typography mode, chip comfort slider + live preview, bloom minute preset, seat ribbon + default seat segmented control, clipboard manifest export, and library wipe.

**Detail / Edit:** `HandEditorPage` opens from any Library row to adjust title and composition with the same palettes as Sketch.

**Booting:** cold start shows a soft gradient with animated petal drift, five pulsing segments, and English lines *East Garden* / *Quiet hands, steady winds ahead* while the namespaced gate resolves routing. A short built-in delay keeps the art from flashing when the network responds instantly.

**Jacket positioning:** Mahjong-adjacent rehearsal reference (not a multiplayer server or live rules engine).

---

## App icon

- **Provided asset** (user input): workspace file `icon/icon_1.png`, copied to `assets/app_icon_source_master.png`, normalized to **`assets/app_icon.png` at 1024×1024** via `sips -z 1024 1024`, then `dart run flutter_launcher_icons`.
- **Style note:** **User-provided artwork** — pastel 3D tile + cherry blossom seascape motif. The default pipeline’s **five-species animal mascot** requirement applies to generated launcher art; **this build uses sponsor-supplied raster per `icon_image_path`, not text-to-image mascot generation.**

---

## Remote config (`remote_url`)

### Endpoint

`https://69f48c3bfb098eb7f0b4896e.mockapi.io/api`

### Mapping (random key → semantic field)

```json
{
  "xvhrtUr": "url",
  "xvhrtPlaf": "platform",
  "xvhrtInpjp": "inappjump",
  "xvhrtEnty": "eventtype",
  "xvhrtAfky": "afkey",
  "xvhrtAid": "appid",
  "xvhrtAdky": "adkey",
  "xvhrtAdelist": "adeventlist"
}
```

### `remote_url` response example (first item is used)

```json
[
  {
    "xvhrtUr": "",
    "xvhrtPlaf": "0",
    "xvhrtEnty": "ad",
    "xvhrtInpjp": "false",
    "xvhrtAfky": "afkeyaaa",
    "xvhrtAid": "000000",
    "xvhrtAdky": "adkeybbbb",
    "xvhrtAdelist": "{\"firstDepositArrival\":\"aaaaa\",\"startTrial\":\"aaaaa\",\"deposit\":\"aaaaa\",\"withdraw\":\"aaaaa\",\"firstOpen\":\"aaaaa\",\"register\":\"aaaaa\",\"depositSubmit\":\"aaaaa\",\"firstDeposit\":\"aaaaa\"}"
  }
]
```

**Where to change the fetched URL:** regenerate with `dart run tools/generate_namespaced_boot_remote.dart apps/east_garden xvhrt --force --endpoint <url>` (keep namespace `xvhrt` aligned with JSON keys) **or** edit `const String xvhrt0` inside `lib/_xvhrt/_xvhrt.dart` together with this README and `马甲包复核说明.md`.

---

## Development

```bash
cd apps/east_garden
flutter pub get
dart run flutter_launcher_icons   # after updating assets/app_icon.png
flutter test
```

Use `flutter run` on device or simulator — the root `MaterialApp` sets `debugShowCheckedModeBanner: false`.
