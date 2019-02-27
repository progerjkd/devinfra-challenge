#!/usr/bin/env python2
import re
from collections import Counter
import sys
#2019-02-26 21:56:28 - conn: 200.129.20.33, proc: 20, err: 404, val: /index.html

def log_reader(logfile):
    myregex = r'\d{1,4}-\d{1,2}\-\d{1,2} \d{1,2}:\d{1,2}:\d{1,2}'

    with open(logfile) as f:
        log = f.read()
        my_datelist = re.findall(myregex,log)
        datecount = Counter(my_datelist)
        for key in sorted(datecount.iterkeys()):
            print("Date " + "=> " + str(key) + " " + "Count "  + "=> " + str(datecount[key]))

if __name__ == '__main__':
    log_reader("error2.log")
