#!/usr/bin/env bash

NODE=$(hdfs fsck -blockId $1 2>/dev/null | grep -o "mipt-node[0-9]*.atp-fivt.org" | head -1)
PATH=$(sudo -u hdfsuser ssh hdfsuser@$NODE find /dfs -name "$1")
echo "$NODE:$PATH"
