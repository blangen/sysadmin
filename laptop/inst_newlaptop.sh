#!/bin/sh

cd ~
curl https://raw.githubusercontent.com/blangen/sysadmin/741deca6/laptop/mac -o mac
curl https://raw.githubusercontent.com/blangen/sysadmin/741deca6/laptop/Brewfile -o Brewfile
/usr/bin/env bash mac 2>&1 | tee ~/new_laptop.log
