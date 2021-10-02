#!/usr/bin/env bash

hdfs fsck $1 -files -blocks -locations 2>/dev/null | grep "Total blocks" | cut -f 2 | cut -d " " -f 1
