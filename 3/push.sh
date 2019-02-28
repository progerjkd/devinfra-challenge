#!/bin/bash

ERR_RATE=$(tail -n 1 /var/log/app.log | awk '{print $9}' | awk -F, '{print $1}')

echo "error_rate $ERR_RATE" | curl --data-binary @- http://pushgateway.prometheus.dunnhumby.example.com:9091/metrics/job/app/instance/3
