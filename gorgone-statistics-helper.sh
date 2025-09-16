#!/bin/bash

# args

file="/etc/default/gorgoned"
severity=$(grep "severity=" $file | cut -d "=" -f5 | tr -d \")


# check if gorgone is in debug mode, if yes, continue, if no, error=>debug; restart gorgoned.service and continue.

check_debug() {
        if [[ "$severity" == "error" ]]
        then
                sed -i "s/severity=$severity/severity=debug/" $file
                systemctl restart gorgoned.service
        fi
        # wait for the total launch of gorgone-httpserver before token request
        echo "wait for 5 seconds for gorgone-httpserver "
        sleep 5
}

restore_debug_to_error() {
    echo "put back to error gorgoned.service "
    sed -i "s/severity=debug/severity=error/" $file
    systemctl restart gorgoned.service
}

# force an engine statistic collection from gorgone, and store the token given by the api in a variable
# note that the port may need to be changed depeding on you configuration, see gorgoned configuration to find you port (in 40-gorgoned.yaml)

token_request() {
        token=$(curl --request GET "http://localhost:8085/api/centreon/statistics/engine"   --header "Accept: application/json" | jq -r .token)

        # gorgone is async, so we need to wait for the collection to be finished before querying for logs
        sleep 5
        echo "sqlite log from engine stat : "
        # this check the sqlite logs, which are not present in the log file.
        curl --request GET "http://localhost:8085/api/log/$token" | jq .
}

check_debug
token_request

# let's check no module did die in the process
echo "ps gorgone : "
ps -aux | grep gorgone

# check the logs from statistics

echo "put last 300 lines of logs from gorgoned.log for gorgone-statistics module into /tmp/log_gorgone_statistics.txt"
tail -n 300 /var/log/centreon-gorgone/gorgoned.log | grep "\[statistics\]" > /tmp/log_gorgone_statistics.txt

restore_debug_to_error
