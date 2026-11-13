# Engine.ini

[Back to the benchmark overview](README.md)

> **Use this at your own risk.** This is not a guide and I am not claiming it is the best config for every PC. It is my personal `Engine.ini`, built around the hardware and scenarios I use. Back up your own file before trying it.
> 
> Don't blame KovaaKs for crashes if you are using modified `Engine.ini`.


> [!CAUTION]
> If you experience any issues after applying the `Engine.ini` please read the [Known Issues](engine-ini.md#known-issues) section, or simply delete the `Engine.ini` file to bring it back to the default state on next Kovaaks launch.



## Installation

1. Back up your current `Engine.ini`.
2. Copy [configs/Engine.ini](configs/Engine.ini) to `%LOCALAPPDATA%\FPSAimTrainer\Saved\Config\WindowsNoEditor` and replace the existing file.
3. Right click `Engine.ini` -> `Properties` -> tick `Read-only`.
4. Close KovaaKs, then copy [configs/aechEngineFix_P.pak](https://github.com/aechXIII/KovaaKs/raw/refs/heads/main/configs/aechEngineFix_P.pak) to `C:\Program Files (x86)\Steam\steamapps\common\FPSAimTrainer\FPSAimTrainer\Content\Paks`.

> [!CAUTION]
> Don't skip step 4. My config breaks some UI elements, without the pak the leaderboard can show an old scenario title, median and scores.
> 
> The pak is made for KovaaKs 3.9.13. It replaces a few UI widgets, so if an update changes them, the pak can break them or hide new stuff. If something looks off after an update let me know.

Benchmarks result are in [README](README.md)

## Fix pak

`Slate.EnableGlobalInvalidation=1` and `Slate.EnableTooltips=0` from my config break some UI elements. [aechEngineFix_P.pak](https://github.com/aechXIII/KovaaKs/raw/refs/heads/main/configs/aechEngineFix_P.pak) fixes them, so you don't have to turn global invalidation off and lose FPS. It doesn't change how scores are submitted.

- Leaderboard updates the scenario title when the board clears or gets a new median. Median, list and score rows redraw too
- `Don't submit score to Leaderboard` checkbox updates right away when you click it
- Crosshair picker shows the file name of the hovered crosshair under the grid, even with tooltips disabled

To remove it, delete the file.

## Known Issues

- #### Checkboxes not refreshing/ UI elements not working properly
  
  Install the [fix pak](#fix-pak) (Installation step 4). If something it doesn't cover is still broken let me know, or set `Slate.EnableGlobalInvalidation=0`. This will significantly decrease FPS

- #### Target glow is missing
  
  Set `r.DefaultFeature.Bloom=1` and `r.BloomQuality=5`

- #### Crash while alt-tabbing or hovering a tooltip
  
  Set `Slate.EnableTooltips=0` and `Slate.AllowToolTips=0`

- #### No tooltips
  
  Remove `Slate.EnableTooltips=0` and `Slate.AllowToolTips=0`. You will have crashed on alt-tabs
  
  If you only miss crosshair names, use the [fix pak](#fix-pak)

---

###### *Not every CVar has been individually tested (majority wasn't). Some are probably redundant or have no measurable effect, but they're left in until I can verify them properly (it will never happen).*

---
