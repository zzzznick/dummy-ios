# Palette Pilot

An offline color lab for building palettes, checking text contrast, mixing colors, and exporting swatches.

## What you get

- **Palettes**: create and edit palettes, reorder and add colors
- **Contrast**: foreground/background preview with AA/AAA target
- **Mixer**: blend two colors and apply the result to a palette
- **Swatches**: tap any swatch to copy in HEX/RGB/HSL
- **Export**: copy text export + preview cards

Settings are stored locally and persist across restarts.

## Boot

Uses `app_common` boot flow (`BootPage → BootCoordinator → RemoteConfigClient`) with a themed orbit animation and a short minimum delay to avoid a one-frame flash.

## App icon

The launcher icon uses an **animal mascot** (Rabbit) in a square 1024×1024 master at `assets/app_icon.png`.

If you regenerate art from a widescreen export, **center-crop to a square** (do not letterbox) before running `flutter_launcher_icons`.

## Build an unsigned IPA-shaped artifact (for inspection)

From repo root:

```bash
bash tools/build_unsigned_ipa.sh apps/palette_pilot
```

This produces `apps/palette_pilot/build/ios/ipa/palette_pilot_unsign.ipa` for static inspection/unzipping/diffing only (not installable on devices).

## Remote config (`remote_url`)

### Endpoint

`https://69ee1d1e9163f839f892848d.mockapi.io/1qkp5`

### Field mapping

The remote config JSON uses per-app random keys. Configure your MockAPI/remote endpoint to respond with these keys.

### Mapping (random key → semantic field)

```json
{
  "vsbwkUr": "url",
  "vsbwkPlaf": "platform",
  "vsbwkInpjp": "inappjump",
  "vsbwkEnty": "eventtype",
  "vsbwkAfky": "afkey",
  "vsbwkAid": "appid",
  "vsbwkAdky": "adkey",
  "vsbwkAdelist": "adeventlist"
}
```

### `remote_url` response example (first item is used)

```json
[
  {
    "vsbwkUr": "",
    "vsbwkPlaf": "0",
    "vsbwkEnty": "ad",
    "vsbwkInpjp": "false",
    "vsbwkAfky": "afkeyaaa",
    "vsbwkAid": "000000",
    "vsbwkAdky": "adkeybbbb",
    "vsbwkAdelist": "{\"firstDepositArrival\":\"aaaaa\",\"startTrial\":\"aaaaa\",\"deposit\":\"aaaaa\",\"withdraw\":\"aaaaa\",\"firstOpen\":\"aaaaa\",\"register\":\"aaaaa\",\"depositSubmit\":\"aaaaa\",\"firstDeposit\":\"aaaaa\"}"
  }
]
```
