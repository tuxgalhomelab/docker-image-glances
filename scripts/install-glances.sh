#!/usr/bin/env bash
set -E -e -o pipefail

export PYENV_ROOT="/opt/pyenv"
export PATH="${PYENV_ROOT:?}/shims:${PYENV_ROOT:?}/bin:${PATH:?}"

echo "Installing Glances ..."

cd /opt/glances
python3 -m venv .
source bin/activate

export PYTHONUNBUFFERED=1
export PYTHONIOENCODING=UTF-8

pip3 install \
    -r requirements.txt \
    -r webui-requirements.txt
