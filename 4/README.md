# My Service
The `After=network.target syslog.target` option, configures the execution order of the service.

With `Restart=always` option enabled, the service shall be restarted when the service process exits, is killed, or a timeout is reached with the exception of a normal stop by the `systemctl stop` command. By default, systemd attempts a restart after 100ms.

When configured with `Restart=always`, systemd gives up restarting the service if it fails to start more than 5 times within a 10 seconds interval, permanently.

There are two `[Unit]` configuration options responsible for this:

    StartLimitBurst=5
    StartLimitIntervalSec=10

The `RestartSec` directive also has an impact on the outcome: if it is set to restart after 3 seconds, then it can never reach 5 failed retries within 10 seconds.

A simple fix is to set `StartLimitIntervalSec=0`. This way, systemd will attempt to restart the service uninterruptedly.

It’s a good idea to set `RestartSec` to at least 1 second though, to avoid putting too much stress on the server when things start going wrong.

## Daemon example
The daemon.php file is a small server using PHP used as example daemon for this question. It will listen to UDP port 10000, and return any message received with a [ROT13](https://en.wikipedia.org/wiki/ROT13) transformation.

Testing it:

    $ netcat -u localhost 10000
    Super secret message.
    Fhcre frperg zrffntr.
