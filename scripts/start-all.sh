#!/bin/bash

filename="$1"
username="$2"
workspaceid="$3"

while read -r line
do
    slave_ip="$line"
	ssh "@username"@"@slave_ip" "sudo chown -R $username:$username /etc/opt/microsoft/omsagent/$workspaceid/conf/"
    #scp -r conf/* "@username"@"@slave_ip":/etc/opt/microsoft/omsagent/"$workspaceid"/conf/
done < "$filename"

