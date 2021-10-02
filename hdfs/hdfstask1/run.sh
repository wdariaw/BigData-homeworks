#!/usr/bin/env bash

BLOCKID=$(hdfs fsck $1 -files -blocks -locations | grep -o "blk_[0-9]*" | head -1)
echo "$(hdfs fsck -blockId $BLOCKID | grep -o "mipt-node[0-9]*.atp-fivt.org" | head -1)"

