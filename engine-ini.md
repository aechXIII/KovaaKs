# Engine.ini

[Back to the benchmark overview](README.md)

> **Use this at your own risk.** This is not a guide and I am not claiming it is the best config for every PC. It is my personal `Engine.ini`, built around the hardware and scenarios I use. Back up your own file before trying it.
> 
> Don't blame KovaaKs for crashes if you are using modified `Engine.ini`.

## Installation

1. Back up your current `Engine.ini`.
2. Copy [configs/Engine.ini](configs/Engine.ini) to `%LOCALAPPDATA%\FPSAimTrainer\Saved\Config\WindowsNoEditor` and replace the existing file.
3. Right click `Engine.ini` -> `Properties` -> tick `Read-only`.

Benchmarks result are in [README](README.md)

## Known Issues

- #### Target glow is missing
  
  Set `r.DefaultFeature.Bloom=1` and `r.BloomQuality=5`
- #### Crash while alt-tabbing or hovering a tooltip
  
  Set `Slate.EnableTooltips=0` and `Slate.AllowToolTips=0`
- #### No tooltips
  
  Remove `Slate.EnableTooltips=0` and `Slate.AllowToolTips=0`. You will have crashed on alt-tabs
- #### Checkboxes not refreshing/ UI elements not working properly
  
  Set `Slate.EnableGlobalInvalidation=0`. This will significantly decrease FPS

---

###### *Not every CVar has been individually tested (majority wasn't). Some are probably redundant or have no measurable effect, but they're left in until I can verify them properly (it will never happen).*

---
