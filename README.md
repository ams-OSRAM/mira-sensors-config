# Mira sensor configs for Arducam USB camera shields

Camera configuration files (`.cfg`) and ISP tuning files (`.yaml`) for ams OSRAM Mira image sensors
on Arducam USB camera shields. They're used by the Arducam Camera GUI (AI-ISP edition), and the
`.cfg` files also work with Arducam's own USB camera tools.

| Sensor | Modes |
| --- | --- |
| Mira016 | 400x400, 200x200 and 100x100, RAW8/RAW10, mono |
| Mira050 | 600x800, RAW8/RAW10, mono |
| Mira220 | 1600x1400, 1280x720, 640x480 and 400x400, RAW10/RAW12; each mode as mono (`_mono`), RGB (`_rgb`, Bayer GBRG) and RGB-IR (`_rgbir`) |

## Hardware

The configs work on both the Arducam USB3 Camera Shield and the USB3 Camera Shield Pro: they use the
Pro board settings, which the older shield accepts too. Connect the shield with a USB 3 cable to a
USB 3 port. Over USB 2.0 the readout overflows the shield and no frames arrive.

## Layout

```
sensors/<sensor>/sensor.yaml     list of modes: display name, .cfg file, optional ISP tuning, status
sensors/<sensor>/*.cfg           Arducam camera config (MIPI setup + sensor register sequence)
sensors/<sensor>/isp/*.yaml      ISP tuning (black/white level, white balance, CCM, gamma)
```

## Controls

Every Mira016 and Mira050 mode has exposure and analog gain sliders in the camera controls panel (Mira220 has its own
frame rate and exposure controls):

| Control | Register | Notes |
| --- | --- | --- |
| Exposure | `EXP_TIME_L` (bank 1, 0x000E) | In time units of the mode, about 1 us |
| Analog Gain | `BIAS_RG_ADCGAIN` + `BIAS_RG_MULT` (bank 0, 0x01F0 / 0x01F3) | 1000 = 1x (the mode's own setting) up to 4000 = 4x |

Analog gain scales the ADC ramp: the gain is proportional to 1 / ((BIAS_RG_ADCGAIN + 21) * 2^BIAS_RG_MULT),
which matches the sensors' gain tables to within 0.5 %. Measured on a Mira050 (all three modes), the
signal follows the requested gain to within 3 % from 1x to 3x. The black level is not compensated:
it rises with gain (in 10-bit mode from about 38 at 1x to about 440 at 3x), so set the ISP black
level to match. Mira050 frames come out white below the minimum exposure (about 70-90 time units,
depending on the mode), which is the slider's lower limit.

The 200x200 and 100x100 Mira016 modes also switch between cropped, subsampled and binned readout,
and set black level and orientation.

`status` is `released` for tested modes or `beta` for modes that work but aren't fully
characterized. The GUI hides beta modes unless you enable them.

## Using a config without the GUI

Open the `.cfg` in any Arducam USB camera tool (*Open config*). The ISP tuning YAML is specific to
the Arducam Camera GUI: load it in its ISP panel.

## Contributing a mode

Add the `.cfg` (and an ISP YAML if you have one) under `sensors/<sensor>/` and list it in that
sensor's `sensor.yaml`. Files that aren't listed in a `sensor.yaml` are ignored by the GUI.

## Releases

Config releases use calendar versioning, `YYYY.MM.N`: year, month, and a counter for releases within
that month (`2026.11.0`, `2026.11.1`, `2026.12.0`). The version is in `VERSION` and tagged
`v<version>`; the Indie Image Sensor Evaluation app shows it next to each sensor. To release, commit
your changes, then:

```powershell
powershell -ExecutionPolicy Bypass -File release.ps1 -Push   # Windows
```

or `bash release.sh --push` on Linux.
