#!/usr/bin/env bash
set -E -e -o pipefail

glances_config="/data/glances/config/glances.conf"

set_umask() {
    # Configure umask to allow write permissions for the group by default
    # in addition to the owner.
    umask 0002
}

start_glances() {
    echo "Starting Glances ..."
    echo
    cd /opt/glances
    source bin/activate

    export PYTHONUNBUFFERED=1
    export PYTHONIOENCODING=UTF-8

    exec python3 -m glances \
        --config ${glances_config:?} \
        --webserver \
        --bind 0.0.0.0 \
        --port 61208 \
        --disable-plugin all \
        --enable-plugin quicklook,fs,system,help,cpu,psutilversion,uptime,load,core,now,version,mem
}

set_umask
start_glances
