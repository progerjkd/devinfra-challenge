# Prometheus Pushgateway sender

 Simple shelll script that sends an app error rate to a Prometheus Pushgateway.

## Running

    ./push.sh

The script will read the error rate from the log file `/var/log/app.log` and push it to the gateway pushgateway.prometheus.dunnhumby.example.com:9091, group `app`, instance `3` and metric name `error_rate`.

## Retrieving metrics
By default, the Pushgateway exposes the pushed metrics via `/metrics` path:

HTTP Request:

    GET http://pushgateway.prometheus.dunnhumby.example.com:9091/metrics

HTTP Response:

    # TYPE error_rate untyped
    error_rate{instance="3",job="app"} 150
