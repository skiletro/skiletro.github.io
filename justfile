[private]
default:
    @just --list --unsorted

[private]
pre:
    nix fmt
    git add .
    nix build .# --print-build-logs

run *args: pre
    nix run .# {{ args }}

watch: (run "watch")

# Build and watch
baw: pre (run "clean") (run "watch")
