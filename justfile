[private]
default:
    @just --list --unsorted

run *args:
    nix fmt
    git add .
    nix build .#
    ./result/bin/site {{ args }}

watch: (run "watch")

# Build and watch
baw:
    nix fmt
    git add .
    nix build .#
    ./result/bin/site clean
    ./result/bin/site build
    ./result/bin/site watch
