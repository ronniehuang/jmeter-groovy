#!/bin/bash

set -e

export JVM_ARGS="-Xms1024m -Xmx4024m"

echo "START Running Jmeter on `date`"
echo "JVM_ARGS=${JVM_ARGS}"

# Keep entrypoint simple: we must pass the standard JMeter arguments

if [[ "${JMETER_MODE}" == "MASTER" ]]; then
    echo "starting JMeter in Master mode"
    #sleep ${SLEEP}
    exec "$@"
elif [[ "${JMETER_MODE}" == "AGENT" ]]; then
    echo "starting Jmeter in Agent mode"
    sleep ${SLEEP}
    exec jmeter-server "$@"
fi