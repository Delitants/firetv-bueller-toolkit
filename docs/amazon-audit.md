# Amazon package audit

The aggressive profile disables Amazon content, Alexa, advertising, telemetry,
OTA, identity, marketplace, Live TV, OTT SSO, casting, sync, tutorial, support,
and cloud-policy packages for user 0. It does not delete APKs from `/system`.
This preserves package-manager rollback and avoids modifying verified system
partitions.

The profile deliberately retains these recovery-critical categories:

- Controller, Bluetooth, Bluetooth DFU, input-device, IME, and key-policy code.
- Amazon communication, discovery, SSDP, and REST services used by remote
  control fallback.
- `com.amazon.awvflingreceiver`, `com.amazon.whisperlink.core.android`,
  `com.amazon.whisperplay.contracts`, and
  `com.amazon.whisperplay.service.install` are explicitly protected because a
  paired WhisperPlay virtual remote is a recovery path when ADB or physical
  input is unavailable.
- Network monitor, smart-connect, Wi-Fi credential locker, captive portal, and
  automatic time-zone components.
- HDMI ARC, audio routing, resolution cycling, and display framework code.
- Settings, unified settings provider, WebView, notification center, low
  storage manager, HOME bootstrap, factory-data-reset watcher, and URL provider.
- Metrics, messaging, device-client, remote-settings, and compatibility SDK
  contract APKs linked by retained framework packages. In particular,
`com.amazon.client.metrics` must remain enabled because framework clients bind
its service during boot; other active collectors and clients are disabled by
the profile.
- `com.amazon.imp`, `com.amazon.identity.auth.device.authorization`, and
  `com.amazon.tv.launcher` remain enabled. They provide the account
  authenticator, identity authorization layer, and HOME boot handoff.

The debloat script checks the protected virtual-remote package set before
making any package changes and stops if the aggressive list contains one of
them. Fire OS 5 also treats its Developer Options debugging toggle as a global
ADB switch: disabling it stops both USB and network ADB. Keep ADB enabled until
the retained virtual remote has been paired and tested, or another local input
path is known to work.

## Live TV ordering

With Amazon Video disabled, a still-running Live TV Station process can query a
missing TV-input provider and flood Fire OS's dropbox logger. The debloat list
therefore includes `com.amazon.tv.livetv`; package changes are sent in short
batches because Fire OS 5 ADB rejects long inline shell commands.
