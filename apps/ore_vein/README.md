# Ore Vein

**Ore Vein** is an **offline-first English utility app** for everyday tasks: interval **Timer**, **Convert** (length, weight, temperature), packing-style **Lists**, restaurant **Tip** math, and saved color **Swatches**. **Settings** lives behind the tune icon and stores preferences locally.

**Jacket type:** tool

**Mainstream clarity:** The bottom navigation reads **Timer · Convert · Lists · Tip · Swatches**, and each tab title matches that wording so the job-to-be-done is obvious without reading this file.

**Boot:** Radial wash plus five animated vertical bars and an indeterminate bar at the bottom (distinct from a single centered spinner).

## App icon

The launcher icon is **user-provided artwork** (not in-pipeline text-to-image). Source backup: `assets/app_icon_source_master.png` (copied from the supplied workspace image). Mascot species: **Dragon** (龙). The master was already **1024×1024**; it was copied to `assets/app_icon.png` and processed with `dart run flutter_launcher_icons`. **Style label:** User-provided artwork (cartoon illustration).

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

Routing uses the namespaced entry in `lib/_qkzmt/_qkzmt.dart` (generated). To change the endpoint later, re-run:

`dart run tools/generate_namespaced_boot_remote.dart apps/ore_vein qkzmt --force --endpoint <your url>`

and keep this README section in sync.
