#!/bin/bash
set -euo pipefail

killall Go2Terminal Go2Terminal.real 2>/dev/null || true
echo "Go2Terminal quit."
