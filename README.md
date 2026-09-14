# Fire TV Bueller Toolkit

A reproducible host-side toolkit for the **Amazon Fire TV 1st Generation**
(`AFTB`, codename `bueller`, model `CL1130`) on Fire OS 5.2.7.4 / Android 5.1.1.
It temporarily obtains root with CVE-2016-5195, aggressively disables Amazon
packages, installs the last Projectivy release compatible with API 22, and can
roll the persistent changes back.

## Exact tested target

| Property | Required value |
| --- | --- |
| `ro.product.model` | `AFTB` |
| `ro.product.device` | `bueller` |
| `ro.build.version.sdk` | `22` |
| `ro.build.version.incremental` | `656639420` |
| Stock `/system/bin/run-as` SHA-256 | `2b7d8d94b4cafa15ad8c55644b835a24d39217e94f2c5b4c9221256055f37864` |

The scripts refuse another model, codename, or Android API. An untested Bueller
build also requires an explicit `ALLOW_UNTESTED_BUILD=1`; the original
`run-as` hash remains guarded separately.

## Important boundaries

- Root is **temporary**. Dirty COW overlays the page cache for
  `/system/bin/run-as`; a reboot restores the original executable.
- Disabled-package state, telemetry settings, and the installed launcher
  persist across reboot. Keep the stock launcher enabled: Fire OS HomeStarter
  requires it to complete boot on the tested Bueller firmware.
- This repository never writes boot, recovery, aboot, system, or an eMMC block
  device. It does not claim a persistent-root or bootloader-unlock path.
- The aggressive profile removes OTA, telemetry, ads, Alexa, Amazon media,
  marketplace, casting, sync, tutorial, support, and other Amazon services.
  Read [`packages/aggressive.txt`](packages/aggressive.txt) before running it.
- Run this only on hardware you own and can recover. Keep power stable.

## Why no CoreELEC or LineageOS image

Bueller is a 32-bit Qualcomm APQ8064 device with a locked historical boot
chain. CoreELEC targets supported Amlogic hardware, and there is no official
LineageOS Bueller build. This pre-Treble Android 5 device cannot use a GSI.
Substituting an image for a related Fire TV model risks an unrecoverable brick.
See [`docs/compatibility.md`](docs/compatibility.md).

## Host prerequisites

Use an Ubuntu or Debian host with the Fire TV already authorized for USB ADB:

```bash
sudo scripts/setup-host.sh
adb devices -l
```

If more than one device is connected, set its serial explicitly:

```bash
export ADB_SERIAL='your-adb-serial'
```

## Build and probe

The build pins the public Dirty COW source to commit
`f5671399e040a168307058c598d62de64bb441d8` and cross-compiles both binaries
locally. No prebuilt exploit binary is shipped.

```bash
scripts/verify-device.sh
scripts/build-root-helper.sh
scripts/probe-vulnerability.sh
scripts/root-command.sh id
```

A successful final command reports `uid=0(root)` and SELinux context
`u:r:shell:s0`. Run it again after every reboot when temporary root is needed.

## Aggressive debloat

```bash
scripts/debloat.sh
```

The script records the disabled-package list and previous settings under
`state/<timestamp>/`, then updates `state/latest`. It executes package-manager
commands directly through the temporary root process because this Fire OS
SELinux policy prevents that process from reading a staged shell script in
`/data/local/tmp`.

## Projectivy Launcher

Projectivy 4.71 declares API 23 and crashes on Android 5.1/API 22 even after a
manifest-only downgrade (`View.setForeground` and newer Material components
are among the incompatible calls). The supplied premium APK is not
redistributed. This toolkit downloads official Projectivy 4.36, the last
release supporting Android 5.1, and verifies its SHA-256.

```bash
scripts/install-projectivy.sh
```

If an existing copy has a different signing certificate, the safe install will
stop. To explicitly erase that app's data and replace it:

```bash
scripts/install-projectivy.sh --replace-existing
```

Complete Projectivy's onboarding on screen. Confirm it opens correctly, then
use the helper to retain/repair the boot-critical stock launcher and start
Projectivy:

```bash
scripts/make-projectivy-home.sh
```

Do not disable `com.amazon.tv.launcher` to force HOME resolution. On this
firmware that leaves `com.amazon.firehomestarter` stuck during the next boot.
After Fire OS completes boot, the helper force-stops the stock launcher's
background process so it consumes no resident memory. Run the helper again
after each reboot, or trigger it from an authorized ADB host.
The accessibility-service toggle is not required to launch Projectivy. On this
Fire OS build, SettingsProvider rejected attempts to set it programmatically.

## Optional Aurora Store

Aurora Store 4.7.5 is pinned because it is the last release supporting Android
5.0/5.1; Aurora 4.8.0 and newer require Android 6. The installer verifies both
the exact upstream APK hash and Aurora OSS signing-certificate fingerprint.

```bash
scripts/install-aurora.sh
```

Aurora is optional and is not run by the root, debloat, or launcher workflows.
See [`docs/amazon-audit.md`](docs/amazon-audit.md) for the Amazon package
keep/remove boundary.

## Rollback

```bash
scripts/rollback.sh
```

Rollback re-enables only packages newly disabled by the recorded run and
restores the four previous settings. It does not uninstall Projectivy.

## License and third-party software

This repository's original scripts and payload are MIT licensed. Dirty COW and
Projectivy are downloaded from their upstream projects and retain their own
licenses. No Amazon firmware, premium APK, private key, device serial, IP
address, or device backup is included.
