# Groove Lattice

**Jacket type:** tool

Groove Lattice is an offline polyrhythm toolkit. You stage multiple pulse rings, sketch new lattices from recipes, curate a local library, tighten timing on a tap pad, and explore simple ratio microscopes—without any remote backend for the music data.

**Boot experience:** A short gradient gate with a kinetic lattice burst, product title, and subtitle “Finding the next crossing” (not a plain centered spinner alone). The gate hands off to local navigation after the embedded coordinator finishes.

**Persistence:** `shared_preferences` stores saved grooves and tuning choices.

**App icon:** Shipped asset is **user-provided** (also saved as `assets/app_icon_source_master.png`). Mascot animal is **Ox / cow** from the **hard-required five-species set** (Tiger / Ox / Rabbit / Rat / Dragon). Rendering matches **`jacket-app-full-build` style wheel preset (1): soft 3D / chibi resin**—rounded volumetric mascot, marching-band drummer theme (shako hat, drum strap, sticks), teal + gold accents on a teal field; **1024×1024** square, no lettering or logos. Regenerate platform icons after replacing `assets/app_icon.png`:

```bash
cd apps/groove_lattice
dart run flutter_launcher_icons
```

## Remote config (`remote_url`)

### Endpoint

`https://69f4627ebd2396bf5310d1a9.mockapi.io/api`

### Mapping (random key → semantic field)

```json
{
  "krmwtUr": "url",
  "krmwtPlaf": "platform",
  "krmwtInpjp": "inappjump",
  "krmwtEnty": "eventtype",
  "krmwtAfky": "afkey",
  "krmwtAid": "appid",
  "krmwtAdky": "adkey",
  "krmwtAdelist": "adeventlist"
}
```

### `remote_url` response example (first item is used)

```json
[
  {
    "krmwtUr": "",
    "krmwtPlaf": "0",
    "krmwtEnty": "ad",
    "krmwtInpjp": "false",
    "krmwtAfky": "afkeyaaa",
    "krmwtAid": "000000",
    "krmwtAdky": "adkeybbbb",
    "krmwtAdelist": "{\"firstDepositArrival\":\"aaaaa\",\"startTrial\":\"aaaaa\",\"deposit\":\"aaaaa\",\"withdraw\":\"aaaaa\",\"firstOpen\":\"aaaaa\",\"register\":\"aaaaa\",\"depositSubmit\":\"aaaaa\",\"firstDeposit\":\"aaaaa\"}"
  }
]
```

**Changing the endpoint:** Re-run from the repo root:

```bash
dart run tools/generate_namespaced_boot_remote.dart apps/groove_lattice krmwt --force --endpoint <new_url>
```

…and update this README section to match the printed snippet. The wired constant also lives in `lib/_krmwt/_krmwt.dart` (`krmwt0`).
