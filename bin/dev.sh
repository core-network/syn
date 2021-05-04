#!/usr/bin/env bash

# Usage:
# bin/dev.sh [number of sandboxes]
#
# this will start hc nodes on ports 8000, 8001, 8002...
# and expose since hc binds to localhost,
# we expose them via socat on 9000, 9001, 9002...

set -euo pipefail

# example:
# die "exit with this error message"
die() { echo "$*" 1>&2 ; exit 1; }

nuke() {
  name=$1
  ( set -x && killall -9 $name ) || true
}

which hc || die "ERROR: executable 'hc' not found in PATH: $PATH"
which socat || die "ERROR: executable 'socat' not found in PATH: $PATH"

nuke hc
nuke holochain
nuke lair-keystore
nuke socat

sandboxes=${1:-2}  # default to 2
port_increment=1
min_port=8000
max_port=$(( min_port + (sandboxes - 1) * port_increment ))

for localhost_port in $(seq $min_port $port_increment $max_port); do
  exposed_port=$(( localhost_port + 1000 ))
  ( set -x && socat TCP-LISTEN:${exposed_port},fork,reuseaddr TCP:127.0.0.1:${localhost_port} & )
done

ports=$(seq -s , $min_port $port_increment $max_port)
set -x
hc sandbox generate \
  --run=${ports} \
  --app-id syn \
  --num-sandboxes ${sandboxes} \
  --root tmp \
  network \
    --bootstrap https://bootstrap-staging.holo.host \
    quic
