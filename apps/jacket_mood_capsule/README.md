# Mood Capsule (Jacket App)

**Type**: Tool app

## Product

**Mood Capsule** is a tiny daily check-in journal. Log a quick mood score, add a short note, and optionally tag or pin entries. Everything is stored locally on device.

## Core model

- `MoodEntry`: mood (1–5), note, tags, pinned, created timestamp

## Key features

- Create / edit / delete mood entries
- Pin important entries to keep them on top
- A simple "Last 7 days" summary on Home
- Settings: theme color, export JSON, clear all data

## Remote config (boot)

This app integrates `food_app_common` boot flow. On startup it fetches remote config and decides navigation; when it routes to local, it opens Mood Capsule.

Remote keyset lives at `lib/boot/remote_config_keys.dart`. For white-label builds, generate a per-app random keyset and README mapping using:

```bash
dart run tools/generate_remote_config_keyset.dart apps/jacket_mood_capsule bkrwr --force
```

## Remote config (`remote_url`)

### Endpoint

`https://69e1e92fb1cb62b9f31779a9.mockapi.io/api2`

### Field mapping

The remote config JSON uses per-app random keys. Configure your MockAPI/remote endpoint to respond with these keys.

### Mapping (random key → semantic field)

```json
{
  "bkrwrUr": "url",
  "bkrwrPlaf": "platform",
  "bkrwrInpjp": "inappjump",
  "bkrwrEnty": "eventtype",
  "bkrwrAfky": "afkey",
  "bkrwrAid": "appid",
  "bkrwrAdky": "adkey",
  "bkrwrAdelist": "adeventlist"
}
```

### `remote_url` response example (first item is used)

```json
[
  {
    "bkrwrUr": "",
    "bkrwrPlaf": "0",
    "bkrwrEnty": "ad",
    "bkrwrInpjp": "false",
    "bkrwrAfky": "afkeyaaa",
    "bkrwrAid": "000000",
    "bkrwrAdky": "adkeybbbb",
    "bkrwrAdelist": "{\"firstDepositArrival\":\"aaaaa\",\"startTrial\":\"aaaaa\",\"deposit\":\"aaaaa\",\"withdraw\":\"aaaaa\",\"firstOpen\":\"aaaaa\",\"register\":\"aaaaa\",\"depositSubmit\":\"aaaaa\",\"firstDeposit\":\"aaaaa\"}"
  }
]
```

