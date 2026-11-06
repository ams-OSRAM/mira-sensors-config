# Mira sensor configs for Arducam USB camera shields

Camera configuration files (`.cfg`) and ISP tuning files (`.yaml`) for ams OSRAM Mira image sensors
on Arducam USB camera shields. They're used by the Arducam Camera GUI (AI-ISP edition), and the
`.cfg` files also work with Arducam's own USB camera tools.

| Sensor | Modes |
| --- | --- |
| Mira016 | 400x400, 200x200 and 100x100, RAW8/RAW10 |
| Mira050 | 600x800, RAW8/RAW10 |
| Mira220 | 1600x1400, 1280x720, 640x480 and 400x400, RAW10/RAW12 |

## Layout

```
sensors/<sensor>/sensor.yaml     list of modes: display name, .cfg file, optional ISP tuning, status
sensors/<sensor>/*.cfg           Arducam camera config (MIPI setup + sensor register sequence)
sensors/<sensor>/isp/*.yaml      ISP tuning (black/white level, white balance, CCM, gamma)
```

## Controls

Every Mira016 and Mira050 mode has these sliders in the camera controls panel (Mira220 has its own
frame rate and exposure controls):

| Control | Register | Notes |
| --- | --- | --- |
| Exposure | `EXP_TIME_L` (bank 1, 0x000E) | In time units of the mode, about 1 us |
| Analog Gain | `BIAS_RG_ADCGAIN` (bank 0, 0x01F0) | Raw ADC gain code, 0-63. Higher is more gain |
| Digital Gain | `GDIG_AMP` (bank 1, 0x0024) | Raw code, 0-255 |

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
