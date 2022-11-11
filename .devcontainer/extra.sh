#!/bin/bash

set -uxe
set -o pipefail

pip install --upgrade pip

## global install of pre-commit
pip install pre-commit
pre-commit install --install-hooks

cd /tmp && sudo rm -rf gitflow && git clone https://github.com/datasift/gitflow && cd gitflow && sudo ./install.sh && sudo git hf upgrade

set +e
hash nextflow >& /dev/null || (
    cd /tmp
    curl -s https://get.nextflow.io | bash
    mkdir -p $HOME/.local/bin
    mv nextflow $HOME/.local/bin/
)
