#!/usr/bin/env python3
import re
import sys


def log_reader(logfile):
    pattern1 = r'err: \d+,'
    pattern2 = r'\d+'

    with open(logfile) as f:
        log = f.readlines()
        last_line = log[-1]
        field = re.search(pattern1, last_line).group()
        error_rate = int(re.search(pattern2, field).group())

        if error_rate <= 10:
            print(f"OK - Error rate: {error_rate} err/s.")
            sys.exit(0)
        elif 10 < error_rate <= 20:
            print(f"WARNING - Error rate: {error_rate} err/s.")
            sys.exit(1)
        elif error_rate > 20:
            print(f"CRITICAL - Error rate: {error_rate} err/s.")
            sys.exit(2)
        else:
            print(f"UNKNOWN - Error rate: {error_rate} err/s.")
            sys.exit(3)


if __name__ == '__main__':
    log_reader('/var/log/app.log')
