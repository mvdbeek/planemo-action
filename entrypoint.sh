#!/bin/sh -l

mkdir -p /home/runner/work/_temp/
ln /github/home /home/runner/work/_temp/_github_home
mkdir /home/runner/work/_temp/_github_home/tmp
export TMPDIR=/home/runner/work/_temp/_github_home/tmp

/planemo_venv/bin/planemo $@
