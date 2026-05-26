# Reduce Memory Cache Script for Linux

## Overview

This project provides a small Linux automation that can drop filesystem caches when available memory is below a configured threshold.

It includes:

- `reduce_memory.sh`: Script that checks memory and optionally runs cache drop.
- `reduce_memory.service`: systemd oneshot service that executes the script.
- `reduce_memory.timer`: systemd timer that triggers the service every 10 minutes.
- `reduce_memory.logrotate`: logrotate rule for `/var/log/reduce_memory.log`.
- `setup.sh`: installer/uninstaller for all components.

## Behavior

The script prefers `MemAvailable` from `/proc/meminfo` to decide whether to drop cache.
If `MemAvailable` is not present, it falls back to `MemFree`.

Default threshold:

- `MEM_MIN = 512` MB

Configuration source precedence:

1. First argument passed to `reduce_memory.sh`
2. `MEM_MIN_ENV` from `/etc/default/reduce_memory`
3. Built-in default (`512`)

## Installation

Clone the repository:

```bash
git clone https://github.com/byfranke/reducememory
cd reducememory
```

Make installer executable and run as root:

```bash
chmod +x setup.sh
sudo ./setup.sh
```

The installer:

- Copies files to `/usr/local/bin` and `/etc/systemd/system`
- Installs `/etc/logrotate.d/reduce_memory`
- Writes `/etc/default/reduce_memory`
- Enables and starts `reduce_memory.timer`

## Custom Installation

When `setup.sh` asks the installation type, select `Custom` and define the threshold in MB.
The selected value is written to `/etc/default/reduce_memory` as `MEM_MIN_ENV`.

## Uninstall

Run:

```bash
sudo ./setup.sh uninstall
```

This disables/stops the timer and removes installed script, systemd units, logrotate config, and environment file.

## Operational Notes

Linux usually manages cache efficiently, so dropping caches frequently can hurt performance.
Use this automation only when you have measured memory pressure and validated the impact on your workload.
