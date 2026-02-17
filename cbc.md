Chordboard Controller (CBC) ZMK Firmware Compilation and Flashing Guide
This README provides step-by-step instructions for compiling and flashing ZMK firmware for the Chordboard Controller (CBC) board. The CBC is a custom keyboard board using the nRF52840 SoC, with support for USB, BLE, encoders, and key scanning via ZMK.
The guide assumes you have already set up the ZMK development environment. If not, follow the official ZMK Setup Guide first, including installing West, the Zephyr SDK, and any required dependencies (e.g., Python venv, CMake, etc.).

Important Notes:
This firmware is configured for the CBC board revision 1.0.0.
The build uses a custom keymap defined in cbc.keymap, which includes chorded combos, encoder bindings, and HID behaviors.
Output format: The config sets CONFIG_BUILD_OUTPUT_UF2=n, so the build produces a .hex file (not UF2).
The board supports multiple flashing methods (e.g., nrfjprog, JLink, DFU), but this guide emphasizes flashing via JLink using nRF Connect for Desktop Programmer.


Prerequisites

Hardware:
Chordboard Controller (CBC) board.
JLink debugger/programmer (e.g., JLink EDU or compatible).

Software:
ZMK repository cloned (e.g., to ~/zmk/zmk.git).
West tool installed and initialized (west init and west update completed).
Zephyr SDK installed (version 0.16.5 or compatible, as shown in the build log).
nRF Connect for Desktop installed (download from Nordic Semiconductor). Install the Programmer app within nRF Connect.
Python 3.10+ with venv for ZMK dependencies.

Directory Structure:
Your custom board files should be in ~/zmk/zmk.git/app/boards/chordboard/cbc/ 
The ZMK app (firmware source) is in ~/zmk/zmk.git/app/.


Step 1: Compile the Firmware

Navigate to the ZMK repository root:textcd ~/zmk/zmk.git
Activate your Python virtual environment (if not already):textsource .venv/bin/activate
Build the firmware for the CBC board: west build -p always -b cbc app
-p always: Pristine the build directory to ensure a clean build.
-b cbc: Specifies the board (from board.yml and other configs).
app: The application directory containing the ZMK firmware source.

This command will:
Use the configurations from files like cbc_defconfig, Kconfig.defconfig, Kconfig.cbc, cbc.dts, cbc.keymap, etc.
Generate build artifacts in ~/zmk/zmk.git/build/.
Output logs similar to the provided build log, including DTC warnings (these are normal for nRF52840 and can be ignored unless they cause errors).

Verify the build:
Check for success: Look for "Linking C executable zephyr/zmk.elf" and memory usage stats.
The key output file is build/zephyr/zephyr.hex (the flashable HEX file for the nRF52840).


If the build fails:

Check for missing dependencies (e.g., run west update again).
Review DTC warnings or Kconfig issues in the log (e.g., the USB_CDC_ACM warning indicates SERIAL dependencies; adjust prj.conf if needed).
Ensure your keymap and DTS files are correctly formatted.

Step 2: Flash the Firmware Using JLink and nRF Connect Programmer
The CBC board supports JLink flashing (configured in board.cmake with args like --device=nRF52840_xxAA --speed=4000). We'll use nRF Connect for Desktop's Programmer app for a graphical, reliable process. This is preferred over command-line tools like west flash --runner jlink for emphasis on manual verification.
Hardware Setup

Connect the JLink to your computer via USB.
Connect the JLink to the CBC board's debug/programming pins (SWD interface: SWDIO, SWCLK, GND, VTref/VCC). The connector for that purpose is the 5 pin header connector located on the bottom left of the board and its pin labels are on the bottom side of the board.
Power the CBC board via USB (it should be detected as an nRF52840 device).
If the board is in a locked state or needs reset, hold any reset button if available, or use soft reset options in the tool.


Flashing Steps

Open nRF Connect for Desktop and launch the Programmer app.
In the Programmer app:
Under Device, click Select device. It should detect your connected JLink and the attached nRF52840 (listed as something like "J-Link - nRF52840_xxAA").
If not detected: Ensure JLink drivers are installed, cables are secure, and the board is powered. Click Refresh or reconnect.

The app will read the device memory automatically (shows regions like UICR, FLASH).

Add the HEX file:
Click Add file > Browse and select ~/zmk/zmk.git/build/zephyr/zephyr.hex.
The successfuly build hex file from my build is present on the compiled folder of the project firmware. You can upload that also.
The file will appear in the File memory layout section. Verify it covers the FLASH region (starting at 0x00000000).

Configure settings (optional but recommended):
Under Device memory layout, ensure the HEX aligns with the partitions from cbc.dts (e.g., MCUBoot at 0x0, image-0 at 0xc000).
Enable Erase all if this is a first-time flash or to clear old firmware.
For recovery: If the device is bricked, enable Recover mode (erases and resets the core).

Write the firmware:
Click Write (or Erase & write if erasing).
The process will:
Erase the FLASH (if selected).
Program the HEX file.
Verify the write.

Monitor the log for success (e.g., "Write successful"). It should take ~10-30 seconds.

Reset and test:
After flashing, click Reset in the Programmer app (or manually reset the board).
Disconnect/reconnect USB to the board.
Test: The board should enumerate as a HID keyboard (check OS device manager). Test keys, encoders, and BLE pairing based on your keymap.


Troubleshooting Flashing

Device not detected: Verify JLink connection, drivers (install from SEGGER), and board power. Use nrfjprog --ids (if installed) to list connected devices.
Write failures:
Speed too high? The config uses --speed=4000; in nRF Connect, adjust under Settings > J-Link speed to 4000 kHz.
Locked device: Use Recover in Programmer to force erase.
Permissions: Run nRF Connect as admin/root if needed.

Verification errors: Rebuild the firmware and ensure the HEX is fresh. Check for DTC warnings in build that might indicate misconfigurations.
Alternative command-line flashing (if GUI fails):textwest flash --runner jlinkThis uses the JLink runner from board.cmake. Install jlink tools from SEGGER if needed.
nrfjprog alternative: If JLink isn't working, use nrfjprog (from Nordic SDK):textnrfjprog --program build/zephyr/zephyr.hex --chiperase --reset

Additional Tips

Customizing Keymap: Edit cbc.keymap for changes (e.g., add more combos). Rebuild and reflash.
BLE Testing: After flashing, pair via Bluetooth (device name "CBC" from Kconfig.defconfig). Use CONFIG_ZMK_BLE_CLEAR_BONDS_ON_START=n to retain bonds.
Battery Reporting: Enabled in config; monitor via HID if implemented.
Updates: Pull latest ZMK/Zephyr changes with west update. Rebuild if configs change.
Logs/Debugging: Enable logging in prj.conf (e.g., CONFIG_LOG=y) for verbose output during development.

If issues persist, check ZMK Discord or GitHub issues for nRF52840-specific problems