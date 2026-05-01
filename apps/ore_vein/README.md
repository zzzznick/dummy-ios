# Ore Vein

Ore Vein is an **English-only** offline field desk for skimming minerals, Mohs hardness, streak checks, toolkit toggles, and trench-side vault notes. Data lives in `shared_preferences`; specimen notes and shaft preferences persist without a gameplay backend.

**Primary surfaces (excluding Shaft controls / settings):**

1. **Atlas** — reference cards sampling common ore-form vibes and field cues (static copy).
2. **Mohs bench** — hardness ladder picker with explanatory blurbs keyed to specimens.
3. **Streak** — palette-backed streak board comparing powder lines at a glance.
4. **Kit** — inspector toggles (density presets, mohs overlays) shaped by persisted settings.
5. **Vault** — saved **Field Notes** with open-in-editor flows and optional compact list density.

**Shaft controls (Settings)** opens from the app-bar splitter icon: theme wash, typography heft, toolkit switches, Vault card density, clipboard manifest, safe wipe paths, and attribution-friendly surfaces without surfacing endpoint copy in UI.

**Detail / Edit:** `FieldNoteEditorPage` launches from Vault rows or the Vault **Add** action (`noteId: null` creates a new specimen card).

**Booting:** cold start shows an animated orbital gate plus *Ore Vein* / *Charting the fracture line* while namespaced bootstrap resolves routing. A short dwell avoids one-frame flashes when the network responds immediately.

---

## App icon

- **Provided asset**: the product illustration is archived as **`assets/app_icon_source_master.png`**; **`assets/app_icon.png`** is the **1024×1024** normalization used by `dart run flutter_launcher_icons`.
- **Style note**: whimsical painterly / storybook illustration — teal baby dragon in a crystal mine, lantern-lit cart **ore**, multifaceted gemstones; warm golds against purple cave walls. Fits the Vault / specimen desk positioning without depicting UI chrome.

---

## Remote config (`remote_url`)

### Endpoint

`https://69f497a4fb098eb7f0b4951c.mockapi.io/api`

### Mapping (random key → semantic field)

```json
{
  "qkzmtUr": "url",
  "qkzmtPlaf": "platform",
  "qkzmtInpjp": "inappjump",
  "qkzmtEnty": "eventtype",
  "qkzmtAfky": "afkey",
  "qkzmtAid": "appid",
  "qkzmtAdky": "adkey",
  "qkzmtAdelist": "adeventlist"
}
```

### `remote_url` response example (first item is used)

```json
[
  {
    "qkzmtUr": "",
    "qkzmtPlaf": "0",
    "qkzmtEnty": "ad",
    "qkzmtInpjp": "false",
    "qkzmtAfky": "afkeyaaa",
    "qkzmtAid": "000000",
    "qkzmtAdky": "adkeybbbb",
    "qkzmtAdelist": "{\"firstDepositArrival\":\"aaaaa\",\"startTrial\":\"aaaaa\",\"deposit\":\"aaaaa\",\"withdraw\":\"aaaaa\",\"firstOpen\":\"aaaaa\",\"register\":\"aaaaa\",\"depositSubmit\":\"aaaaa\",\"firstDeposit\":\"aaaaa\"}"
  }
]
```

**Where to change the fetched URL:** regenerate with  
`dart run tools/generate_namespaced_boot_remote.dart apps/ore_vein qkzmt --force --endpoint <url>`  
(keep namespace `qkzmt` aligned with JSON keys) **or** edit `const String qkzmt0` inside `lib/_qkzmt/_qkzmt.dart` together with this README and `马甲包复核说明.md`.

---

## Development

```bash
cd apps/ore_vein
flutter pub get
dart run flutter_launcher_icons   # after updating assets/app_icon.png
flutter test
```

Use `flutter run` on device or simulator — the root `MaterialApp` sets `debugShowCheckedModeBanner: false`.
