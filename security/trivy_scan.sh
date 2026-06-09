#!/usr/bin/env bash
set -euo pipefail

image="${1:-securebank:latest}"

trivy image --severity CRITICAL,HIGH --exit-code 1 --ignore-unfixed "$image"
