[private]
default:
    @just --list --unsorted

run *args:
    nix build .#
    ./result/bin/site {{ args }}

watch: (run "watch")

# Build and watch
baw:
    nix build .#
    ./result/bin/site clean
    ./result/bin/site build
    ./result/bin/site watch
