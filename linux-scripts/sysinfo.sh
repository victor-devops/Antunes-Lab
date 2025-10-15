#!/usr/bin/env bash
set -euo pipefail
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -sr)"
echo "Uptime: $(uptime -p)"
''