#!/bin/sh

cd ~
wget https://github.com/blangen/sysadmin/blob/develop/laptop/Brewfile
wget https://github.com/blangen/sysadmin/blob/develop/laptop/mac
/usr/bin/env bash mac 2>&1 | tee ~/new_laptop.log
