## Manual verification checklist

### Boot routing (remote config)
- [ ] Remote config returns empty `url` → app enters LocalTabs
- [ ] Remote config returns non-empty `url` + `platform="1"` → enters Web Shell One and loads URL
- [ ] Remote config returns non-empty `url` + `platform="2"` → enters Web Shell Two and loads URL
- [ ] Remote config returns non-empty `url` + `platform="3"` → opens URL externally

### Web Shell One
- [ ] `window.jsBridge` and `window.WgPackage` exist on page
- [ ] JS channel `Post` accepts `{name,data}`; non-`openWindow` calls analytics without crash
- [ ] `openWindow` opens externally when `inappjump != "true"`
- [ ] `openWindow` loads in-app when `inappjump == "true"`
- [ ] Navigation to host containing `t.me` opens externally

### Web Shell Two
- [ ] Custom User-Agent includes `AppShellVer:1.0.0` and `UUID:`
- [ ] JS channel `eventTracker` accepts `{eventName,eventValue}` (eventValue string/object)
- [ ] JS channel `openSafari` opens externally when `inappjump != "true"`
- [ ] Navigation to host containing `t.me` opens externally

### LocalTabs
- [ ] Feast/Recipes/Diary: add/list/detail/delete works
- [ ] Feast: search + sort + total cost works
- [ ] LocalTabs entry triggers feast restore when backup exists
- [ ] Image pickers store file and show thumbnails/details

