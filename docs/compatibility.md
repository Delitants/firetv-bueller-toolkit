# Compatibility and recovery research

## Verified device facts

The tested unit identifies as Amazon `AFTB` / `bueller`, uses 32-bit ARMv7 on
Qualcomm APQ8064/MSM8960, and runs Fire OS 5.2.7.4 build `656639420` (Android
5.1.1, API 22). Amazon's current software-update table lists 5.2.7.4 as the
latest official software for Fire TV 1st Generation.

## ROM conclusions

- **CoreELEC:** not a Bueller target. Current CoreELEC device support is built
  around supported Amlogic platforms, not this Qualcomm APQ8064 Fire TV.
- **LineageOS:** no official `bueller` device download/build exists. A generic
  system image is not an alternative because this device predates Project
  Treble.
- **Historical unlock:** public Bueller unlock work targeted old bootloader
  generations. Reports indicate Amazon's 51.1.4.1 update permanently closed
  the downgrade route by programming an eFuse. The tested unit is much newer.
- **EDL/fastboot:** `adb reboot edl` on the tested device only rebooted it back
  to normal Lab126 USB ADB. No usable fastboot or EDL flashing interface was
  established.
- **Hardware recovery:** eMMC access has been documented by hardware hackers,
  but it is invasive and does not create a verified compatible ROM or safely
  undo a fused bootloader policy.

## Sources

- Amazon Fire TV software updates:
  <https://digprjsurvey.amazon.com/csad/help/node/G201497590>
- CoreELEC supported devices:
  <https://coreelec.org/>
- LineageOS devices:
  <https://wiki.lineageos.org/devices/>
- Historical Bueller bootloader unlock:
  <https://github.com/rhcp011235/firetv_bootloader_unlock>
- postmarketOS Bueller notes:
  <https://wiki.postmarketos.org/wiki/Amazon_Fire_TV_%28amazon-bueller%29>
- Bueller eMMC hardware work:
  <https://solderwiresandplastic.com/tag/firetv/>
- Dirty COW helper source:
  <https://github.com/timwr/CVE-2016-5195>
- Projectivy 4.36 release:
  <https://github.com/spocky/miproja1/releases/tag/4.36>

