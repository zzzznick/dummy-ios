# Gauge Grid

**Product (English)**: Gauge Grid is an offline **measurement board** for workshop or layout notes. You **tap cells** on a resizable **grid** to type values, **save named boards** to recall later, and use a **length converter** (mm / cm / in) in one place. **Jacket type**: tool

**Visible primary blocks (3, excluding Settings)**: see bottom navigation: **Grid**, **Boards**, **Convert**. **Settings** is the app-bar **gear** (full screen).

- **Grid**: N×N cells (4–12 in Settings); tap to edit, clear, or **Save board**.
- **Boards**: list of saved patterns; **load** to replace the live grid, swipe to **delete** a card.
- **Convert**: one-off length conversion; honors **default unit** and **decimal places** from Settings.
- **Boot & remote**: cold start uses `app_common` `BootPage` → `BootCoordinator` → `RemoteConfigClient`. `remote_url` returns a **JSON array**; the **first** object is parsed with per-app **random key names** (see below). The sample endpoint at [MockAPI 1qkp5](https://69ee1d1e9163f839f892848d.mockapi.io/1qkp5) is often an **empty `[]`**, so the app stays on the local shell.

**Boot**: Teal **gradient** + “Dialing the grid” + **animated concentric ring** painter, bottom **tweening progress** bar, ~0.5s minimum visual so the first frame is not a flash if config resolves fast.

**Persistence**: `gauge_grid_state.json` under the app documents directory. **No network** required for the core app.

**App icon**: 1024×1024 `assets/app_icon.png`. This build uses a **cute 3D chibi zodiac rabbit (兔) mascot** (cartoon, 满框). Source export was **widescreen**; use **largest center square** crop, **not** top/bottom letterbox. Run: `dart run flutter_launcher_icons` after replacing the master. Optional wide source: `assets/app_icon_source_wide.png`.

## Remote config (`remote_url`)

### Endpoint

`https://69ee1d1e9163f839f892848d.mockapi.io/1qkp5`

### Field mapping

The remote config JSON uses per-app random keys. Configure your MockAPI/remote endpoint to respond with these keys.

### Mapping (random key → semantic field)

```json
{
  "gzeqpUr": "url",
  "gzeqpPlaf": "platform",
  "gzeqpInpjp": "inappjump",
  "gzeqpEnty": "eventtype",
  "gzeqpAfky": "afkey",
  "gzeqpAid": "appid",
  "gzeqpAdky": "adkey",
  "gzeqpAdelist": "adeventlist"
}
```

### `remote_url` response example (first item is used)

```json
[
  {
    "gzeqpUr": "",
    "gzeqpPlaf": "0",
    "gzeqpEnty": "ad",
    "gzeqpInpjp": "false",
    "gzeqpAfky": "afkeyaaa",
    "gzeqpAid": "000000",
    "gzeqpAdky": "adkeybbbb",
    "gzeqpAdelist": "{\"firstDepositArrival\":\"aaaaa\",\"startTrial\":\"aaaaa\",\"deposit\":\"aaaaa\",\"withdraw\":\"aaaaa\",\"firstOpen\":\"aaaaa\",\"register\":\"aaaaa\",\"depositSubmit\":\"aaaaa\",\"firstDeposit\":\"aaaaa\"}"
  }
]
```

## Dev

```bash
cd apps/gauge_grid
flutter pub get
dart run flutter_launcher_icons
flutter test
```

## Endpoints in code

- `lib/boot/remote_config_endpoint.dart` → `remoteConfigEndpoint`
- `lib/boot/remote_config_keys.dart` → `remoteConfigKeys`

Update both when you re-run:  
`dart run tools/generate_remote_config_keyset.dart apps/gauge_grid <new_prefix> --force --endpoint <url>` (from repository root)
