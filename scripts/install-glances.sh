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

pip3 install uv

# Hack to point .venv-uv/bin/uv -> bin/uv from the venv uv we just
# installed above. This is needed because the Makefile expects
# uv at this specific location unfortunately.
mkdir -p .venv-uv
ln -s ../bin .venv-uv/bin

make requirements-all

pip3 install -r all-requirements.txt
