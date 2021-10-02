#!/usr/bin/env python

import sys
import re
import random

reload(sys)
sys.setdefaultencoding('utf-8')

for line in sys.stdin:
    try:
        id = unicode(line.strip())
    except ValueError as e:
        continue
    print "%d\t%s" % (random.randint(1, 1000), id)

