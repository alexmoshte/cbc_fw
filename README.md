# Chordboard Controller (CBC) – ZMK Firmware Guide

This document provides step-by-step instructions for **compiling and flashing ZMK firmware** for the **Chordboard Controller (CBC)** board.

The CBC is a custom keyboard based on the **nRF52840 SoC**, supporting:

* USB
* Bluetooth Low Energy (BLE)
* Rotary encoders
* Matrix key scanning via ZMK

>  This guide assumes you have already set up the ZMK development environment.

---

##  Important Notes

* Firmware is configured for **CBC board revision 1.0.0**
* Uses a custom keymap (`cbc.keymap`) with:

  * Chorded combos
  * Encoder bindings
  * HID behaviors
* Output format:

  * `CONFIG_BUILD_OUTPUT_UF2=n`
  * Produces a `.hex` file (not UF2)
* Flashing methods supported:

  * J-Link (recommended in this guide)
  * nrfjprog
  * DFU

---

##  Prerequisites

###  Hardware

* CBC board
* J-Link debugger (e.g., J-Link EDU or compatible)

###  Software

* ZMK repository cloned (e.g., `~/zmk/zmk.git`)
* West tool initialized (`west init`, `west update`)
* Zephyr SDK (v0.16.5 or compatible)
* nRF Connect for Desktop (with Programmer app)
* Python 3.10+ with virtual environment

###  Directory Structure

```
~/zmk/zmk.git/
├── app/
│   └── boards/chordboard/cbc/
└── build/
```

---

##  Step 1: Compile the Firmware

### 1. Navigate to the repository

```
cd ~/zmk/zmk.git
```

### 2. Activate virtual environment

```
source .venv/bin/activate
```

### 3. Build firmware

```
west build -p always -b cbc app
```

### 🔍 What This Does

* Cleans previous builds (`-p always`)
* Uses board configuration (`-b cbc`)
* Compiles ZMK firmware

###  Output Files

```
build/zephyr/zephyr.hex   ← Flash this file
```

###  Verify Build Success

Look for:

* `Linking C executable zephyr/zmk.elf`
* Memory usage summary

---

###  If Build Fails

* Run:

  ```
  west update
  ```
* Check:

  * DTS warnings
  * Kconfig issues
  * `prj.conf` dependencies (e.g., USB_CDC_ACM warnings)
* Validate:

  * `cbc.keymap`
  * `cbc.dts`

---

##  Step 2: Flash Firmware (J-Link + nRF Connect)

### 🔌 Hardware Setup

1. Connect J-Link to PC via USB
2. Connect J-Link to CBC via SWD:

   * SWDIO
   * SWCLK
   * GND
   * VCC (VTref)

>  Connector: 5-pin header (bottom-left of board)

3. Power the board via USB

---

###  Flashing Steps

#### 1. Open Programmer

* Launch **nRF Connect for Desktop**
* Open **Programmer**

#### 2. Select Device

* Choose detected J-Link device (e.g., `nRF52840_xxAA`)
* Click **Refresh** if not visible

#### 3. Add Firmware

* Click **Add file**
* Select:

  ```
  build/zephyr/zmk.hex

  or *projectpath*\compiled\zmk.hex
  ```

#### 4. Configure Options (Recommended)

* Enable **Erase all**
* Ensure correct memory layout:

  * Bootloader: `0x0000`
  * Application: `0xC000`

#### 5. Flash

* Click **Write** or **Erase & Write**
* Wait (~10–30 seconds)

#### 6. Reset & Test

* Click **Reset**
* Reconnect USB
* Verify:

  * Device appears as HID keyboard
  * Keys & encoders function
  * BLE pairing works

---

##  Troubleshooting

### Device Not Detected

* Check wiring
* Reinstall J-Link drivers
* Ensure board is powered

### Flash Failures

* Reduce J-Link speed to **4000 kHz**
* Use **Recover** option if locked

### Verification Errors

* Rebuild firmware
* Confirm `.hex` is up to date

---

##  Alternative Flash Methods

### Using West

```
west flash --runner jlink
```

### Using nrfjprog

```
nrfjprog --program build/zephyr/zephyr.hex --chiperase --reset
```

---

## Additional Tips

### Keymap Customization

Edit:

```
cbc.keymap
```

Then rebuild & flash.

---

### BLE Behavior

* Device name: `"CBC"`
* To retain bonds:

```
CONFIG_ZMK_BLE_CLEAR_BONDS_ON_START=n
```

---

### Debugging

Enable logging in `prj.conf`:

```
CONFIG_LOG=y
```

---

### Updating Dependencies

```
west update
```

---

## Support

If issues persist:

* Check ZMK GitHub issues
* Ask in ZMK Discord
* Verify nRF52840-specific configurations

---

 You’re now ready to build, flash, and iterate on your CBC firmware.
