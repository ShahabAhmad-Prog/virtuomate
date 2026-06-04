# Optional Rive coach overlay (Layer 2)

Sprite emotion transitions work without this file.

To enable the Rive overlay:

1. Create a character in [Rive](https://rive.app) with state machine **`Coach`**
2. Inputs (recommended):
   - `mouthOpen` (Number, 0–100)
   - `happy`, `thinking`, `speaking` (Booleans)
3. Export as `coach_avatar.riv` into this folder
4. Set `enableRiveOverlay: true` on `AvatarPresence` where desired

Or run: `.\tool\download_rive_coach.ps1` (if a public sample URL is configured).
