# check_err_rate Nagios plugin
Write a simple nagios plugin that alerts when the error rate of a service is higher than 10/s (warning) and higher than 20/s (critical).
Error rate is reported via a log file which is written every 30 seconds.



The log file has the following format:

    <YYYY-MM-DD hh:mm:ss> - conn: <C>, proc: <P>, err: <E>, val: <V>
    
Where all `<C>, <P>, <E>, <V>` are integers and `<E>` is the error rate per second. Let's say the log file is stored in /var/log/app.log.


## On the client host:

Copy the plugin file `check_err_rate.py` to the nagios plugin directory `/usr/lib/nagios/plugins/`

 `chmod 755 /usr/lib/nagios/plugins/check_err_rate.py`
 
 Add the `command` parameter to the client `/etc/nagios/nrpe.cfg` file:

`command[check_err_rate]=/usr/lib/nagios/plugins/check_err_rate.py`

 Restart Nagios NRPE service:
 
 `systemctl restart nrpe`

## On the Nagios server:

 Create a new service definition file `/usr/local/nagios/etc/services/service monitoring.cfg` and assign the Nagios client to its `host_name` parameter:

    define service {
        host_name              client.example.org
        service_description    Check service error rate
        use                    generic-service
        check_command          check_nrpe!check_err_rate!!!!!!!
        max_check_attempts     5
        check_interval         0.5
        check_period           24x7
        notification_period    24x7
        register               1
    }
    
 Restart the Nagios server to apply the changes:
 
`systemctl restart nagios` 



