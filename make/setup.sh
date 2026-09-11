#!/usr/bin/env bash
set -euo pipefail

BAL_VERSION=2201.13.5

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

main() {
    echo "── submodules (remote HEADs) ──"
    git submodule update --init --remote
    git submodule status

    echo "── ballerina $BAL_VERSION ──"
    install_ballerina

    echo "── prerequisites ──"
    doctor
}

install_ballerina() {
    local dir="downloads/ballerina-$BAL_VERSION-swan-lake-$(bal_platform)"

    if [[ ! -x "$dir/bin/bal" ]]; then
        local url="https://github.com/ballerina-platform/ballerina-distribution/releases/download/v$BAL_VERSION/$(basename "$dir").zip"
        echo "downloading $url"
        curl -fL --progress-bar -o downloads/bal.zip "$url"
        unzip -q -o downloads/bal.zip -d downloads
        rm downloads/bal.zip
        chmod +x "$dir"/bin/bal "$dir"/dependencies/*/bin/* 2>/dev/null || true
    fi

    "$dir/bin/bal" version | head -1
}

bal_platform() {
    case "$(uname -s)-$(uname -m)" in
        Darwin-arm64)  echo macos-arm ;;
        Darwin-x86_64) echo macos-x64 ;;
        Linux-aarch64) echo linux-arm ;;
        Linux-x86_64)  echo linux-x64 ;;
        *) echo "unsupported platform: $(uname -sm)" >&2; return 1 ;;
    esac
}

doctor() {
    local missing=()

    require java  "builds and runs everything"
    require git   "submodules"
    require curl  "downloads, lab health checks"
    require unzip "dist zips"

    optional mvn        "make mi"
    optional docker     "labs db-opsh-docker, proxied"
    optional opensearch "lab bare-bi"
    optional fluent-bit "lab bare-bi"

    (( ${#missing[@]} == 0 )) || { echo "install: ${missing[*]}" >&2; return 1; }
    echo "ready — try: make icp && make start bare-mi"
}

require() {
    if command -v "$1" >/dev/null; then
        printf '  ok       %-11s %s\n' "$1" "$2"
    else
        printf '  MISSING  %-11s %s\n' "$1" "$2"
        missing+=("$1")
    fi
}

optional() {
    if command -v "$1" >/dev/null; then
        printf '  ok       %-11s %s\n' "$1" "$2"
    else
        printf '  absent   %-11s %s\n' "$1" "$2"
    fi
}

main "$@"
