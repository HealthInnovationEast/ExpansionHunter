#!/bin/bash

set -u

hash nextflow >& /dev/null || (
    cd /tmp
    curl -s https://get.nextflow.io | bash
    mkdir -p $HOME/.local/bin
    mv nextflow $HOME/.local/bin/
)