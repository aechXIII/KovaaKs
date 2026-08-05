# My collection of KovaaK's resources

At the moment the repository only includes an optimized `Engine.ini`, but more content will be added, maybe.

---

## Engine.ini
> **Use this at your own risk.**
> This is not a guide and I am not claiming it is the best config for every PC. It is my personal `Engine.ini`, built around the hardware and scenarios I use. Back up your own file before trying it.  

> Don't blame KovaaKs for crashes if you are using modified `Engine.ini`.

### Tested on

- AMD Ryzen 7 9800X3D
- RTX 4080 Super
- 32 GB DDR5-6000 CL30
- Windows 10.0.26100 Build 26100

### Tools

- CapFrameX

### Results
Tested on `pasu small reload` and `Controlsphere`  

public = this config  
default = stock Engine.ini  

<p align="center">
  <img src="images/benchmark.png" width="900">
</p>

**Your results WILL BE DIFFERENT.**

### Installation

Copy:

```
configs/Engine.ini
```

to

```
%LOCALAPPDATA%\FPSAimTrainer\Saved\Config\WindowsNoEditor
```

Replace your existing `Engine.ini`.

It's recommended to make a backup first. If anything goes wrong, just delete the custom file and KovaaK's will generate a clean one on next launch.

**You HAVE TO set the file to **Read only**, you don't want the game to overwrite it.**

**In game, enable One Thread Frame Lag in Video settings, turn off Nvidia Reflex.**

### Lower latency

The included config is mainly aimed at improving performance and frame consistency.
If you want to prioritize lower latency instead, try changing:

```ini
r.OneFrameThreadLag=0
```

For a more aggressive approach you can also test:

```ini
r.FinishCurrentFrame=1
r.GTSyncType=1
r.RHI.MaximumFrameLatency=1
```

`r.FinishCurrentFrame=1` is most likely not worth it.

As always, test what works best on your own system.

### Known Issues
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
