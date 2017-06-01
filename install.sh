#!/bin/bash

# The script takes 3 parameters: <cluster type> <OMS workspace ID> <OMS primary key>
# <cluster type> is passed by RP, the available values are hadoop, interactivehive, hbase, kafka, kafkafs, storm, spark. Refer to $Current\src\HadoopServices\RDFE\DeploymentAPIService\ResourceTypes\IaasClusterHandlers\Common\IaasClusterHandlersUtils.cs
# <OMS workspace ID> is passed by user inputs
# <OMS primary key> is passed by user inputs
# For local testing, you can use script action to run your modified scripts and pass the three parameters.

configure_hbasecluster()
{
    if [[ $HOSTNAME == hn* ]];
    then
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/yarnconf/yarn.headnode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/yarn.headnode.conf
    elif [[ $HOSTNAME == wn* ]];
    then
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/yarnconf/yarn.workernode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/yarn.workernode.conf
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/hbaseconf/hbase.workernode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/hbase.workernode.conf
    elif [[ $HOSTNAME == zk* ]];
    then
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/hbaseconf/hbase.zookeeper.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/hbase.zookeeper.conf
    fi
}

configure_sparkcluster()
{
    if [[ $HOSTNAME == hn* ]];
    then
      sudo wget https://zhunansparkstorage.blob.core.windows.net/oms/spark_headnode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/spark.headnode.conf
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/yarnconf/yarn.headnode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/yarn.headnode.conf
    elif [[ $HOSTNAME == wn* ]];
    then
      sudo wget https://zhunansparkstorage.blob.core.windows.net/oms/spark_workernode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/spark.workernode.conf
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/yarnconf/yarn.workernode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/yarn.workernode.conf
    fi
}

configure_hadoop()
{
    if [[ $HOSTNAME == hn* ]];
    then
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/yarnconf/yarn.headnode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/yarn.headnode.conf
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/hive/hive.headnode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/hive.headnode.conf
    elif [[ $HOSTNAME == wn* ]];
    then
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/yarnconf/yarn.workernode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/yarn.workernode.conf
    fi
}

configure_interactivehive()
{
    if [[ $HOSTNAME == hn* ]];
    then
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/yarnconf/yarn.headnode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/yarn.headnode.conf
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/hive/interactivehive.headnode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/interactivehive.headnode.conf
    elif [[ $HOSTNAME == wn* ]];
    then
      sudo wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/yarnconf/yarn.workernode.conf -O /etc/opt/microsoft/omsagent/conf/omsagent.d/yarn.workernode.conf
    fi
}

#------------------------------------------------------------------
#  MAIN
#------------------------------------------------------------------

wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/omsagent/omsagent.x64.sh -O /tmp/omsagent.x64.sh
sudo sh /tmp/omsagent.x64.sh --upgrade
sudo sh -x /opt/microsoft/omsagent/bin/omsadmin.sh -w $2 -s $3

if [[ $1 == hbase ]];
then
  configure_hbasecluster
elif [[ $1 == spark ]];
then
  configure_sparkcluster
elif [[ $1 == hadoop ]];
then
  configure_hadoop
elif [[ $1 == interactivehive ]];
then
  configure_interactivehive
fi

#----------------------------------------------------------------
#  patch fluentd for a known issue found by customer
#----------------------------------------------------------------
wget https://hdiconfigactions.blob.core.windows.net/clustermonitoringconfigactionv01/omsagent/in_exec.patch
sudo patch -p0 -N /opt/microsoft/omsagent/ruby/lib/ruby/gems/2.3.0/gems/fluentd-0.12.24/lib/fluent/plugin/in_exec.rb < in_exec.patch
sudo rm in_exec.patch

sudo /opt/microsoft/omsagent/bin/service_control restart
