# Asset generation rules

## When to generate
Create a new asset via nanobanana MCP when the code references a file that doesn't exist and is essential (enemy sprites, projectiles, animations, UI elements, SFX placeholders).

## Style guide
- Match the style of existing assets in `assets Nikita/`
- 2D pixel-art / flat art style, consistent with existing soldier and egg sprites
- Transparent background (PNG)
- Resolution: roughly matching existing sprites (check reference files for dimensions)
- Naming convention: `{type}_{id}_{state}.png` (e.g., `enemy_01_walk.png`, `bullet_01.png`)

## Storage
Save new assets into the appropriate subfolder of `assets Nikita/`:
- `backgrounds/` — level backgrounds, UI backgrounds
- `buttons/` — UI buttons
- `cells/` — grid cell textures
- `eggs/` — alien egg/ spawner sprites
- `icons/` — UI icons
- `levels/` — level state indicators
- `logo/` — game logo
- `music/` — audio tracks (MP3)
- `soldiers/` — soldier sprites and animations
- If no fitting category exists, place at `assets Nikita/` root

## Prompt structure for nanobanana
Reference existing sprites from `assets Nikita/` folder to match style, then describe:
- Subject (what it is)
- Action/state (idle, attack, walk, etc.)
- Style (2D game asset, pixel-art, matching [reference file])
- Palette colors to match existing assets
- Output format: transparent PNG

## Approval
Generate on the fly without asking. Later redo specific assets if needed.

## Yandex Games requirements (target platform)
- **SDK mandatory** — Yandex Games SDK must be integrated (moderation will reject without it)
- **LoadingAPI.ready()** — call when the game is fully loaded and playable
- **Auto language** — use `ysdk.environment.i18n.lang` for UI language, never manual selection
- **Pause/Resume** — listen to `ysdk.on('game_api_pause')` / `ysdk.on('game_api_resume')`; pause game loop accordingly
- **Payments** — only through Yandex Games SDK
- **No external logins/links** — users must not need third-party auth
- **Export format** — HTML5 (WebGL), Godot HTML5 export template

## Missing categories (known gaps)
- Enemy/alien sprites (walk, attack, death animations)
- Soldier attack/shoot animations (only idle exists)
- Projectiles / bullets
- Sound effects (shoot, explosion, coin, UI click)
