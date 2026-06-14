default:
    @just --list

build:
    #!/usr/bin/env bash
    set -euo pipefail
    hugo_args=(--gc --minify)
    if [[ -n "${HUGO_BASEURL:-}" ]]; then
      hugo_args+=(--baseURL "${HUGO_BASEURL}")
    fi
    hugo "${hugo_args[@]}"
    cd presentations
    OUTPUT_ROOT=../public/presentations just build-all

clean:
    rm -rf public resources
    cd presentations && just clean
