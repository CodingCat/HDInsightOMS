#!/bin/bash

set -x

username="$1"
workspaceid="070bd68b-c755-48a2-9e17-43c469b50a86"

HEADNODELIST=`cat headnodes`

WORKERNODELIST=`cat workernodes`

for slave_ip in `echo $HEADNODELIST|sed  "s/#.*$//;/^$/d"`; do
    echo $slave_ip
    ssh $username@$slave_ip sudo chown -R $username:$username /etc/opt/microsoft/omsagent/$workspaceid/conf/
    scp -r conf/spark.headnode.conf $username@$slave_ip:/etc/opt/microsoft/omsagent/conf/omsagent.d
    ssh $username@$slave_ip "sudo pkill -9 -f 'omsagent';sudo killall -9 -u omsagent"
    ssh $username@$slave_ip sudo /opt/microsoft/omsagent/ruby/bin/ruby /opt/microsoft/omsagent/bin/omsagent -d /var/opt/microsoft/omsagent/$workspaceid/run/omsagent.pid -o /var/opt/microsoft/omsagent/$workspaceid/log/omsagent.log -c /etc/opt/microsoft/omsagent/$workspaceid/conf/omsagent.conf --no-supervisor
done

for slave_ip in `echo $WORKERNODELIST|sed  "s/#.*$//;/^$/d"`; do
    echo $slave_ip
    ssh $username@$slave_ip sudo chown -R $username:$username /etc/opt/microsoft/omsagent/$workspaceid/conf/
    scp -r conf/spark.workernode.conf $username@$slave_ip:/etc/opt/microsoft/omsagent/conf/omsagent.d
    ssh $username@$slave_ip "sudo pkill -9 -f 'omsagent';sudo killall -9 -u omsagent"
    ssh $username@$slave_ip sudo /opt/microsoft/omsagent/ruby/bin/ruby /opt/microsoft/omsagent/bin/omsagent -d /var/opt/microsoft/omsagent/$workspaceid/run/omsagent.pid -o /var/opt/microsoft/omsagent/$workspaceid/log/omsagent.log -c /etc/opt/microsoft/omsagent/$workspaceid/conf/omsagent.conf --no-supervisor
done 





