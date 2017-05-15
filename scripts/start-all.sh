#!/bin/bash

filename="$1"
username="$2"
workspaceid="91bc00a4-5b39-45a8-9a2e-f0a9ca9328c9"


while read -r line; do
    slave_ip="$line"
	ssh $username@$slave_ip sudo chown -R $username:$username /etc/opt/microsoft/omsagent/$workspaceid/conf/
    scp -r conf/* $username@$slave_ip:/etc/opt/microsoft/omsagent/$workspaceid/conf/
	ssh $username@$slave_ip sudo /opt/microsoft/omsagent/ruby/bin/ruby /opt/microsoft/omsagent/bin/omsagent -d /var/opt/microsoft/omsagent/$workspaceid/run/omsagent.pid -o /var/opt/microsoft/omsagent/$workspaceid/log/omsagent.log -c /etc/opt/microsoft/omsagent/$workspaceid/conf/omsagent.conf --no-supervisor
done <$filename

