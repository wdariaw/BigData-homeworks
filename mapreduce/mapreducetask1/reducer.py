#!/usr/bin/env python3.6

import sys
import random
import re

cur_num = 0
num_ids = random.randint(1, 5)
num_lines = 0

for line in sys.stdin:
    if num_lines == 50:
        continue
    try:
        key, id = line.strip().split('\t', 1)
    except ValueError as e:
        continue
    if cur_num == num_ids - 1:
        print(id)
        cur_num = 0
        num_ids = random.randint(1, 5)
        num_lines = num_lines + 1
    else:
        print(id, end=',')
        cur_num = cur_num + 1
