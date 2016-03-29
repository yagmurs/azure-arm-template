#!/bin/bash

set -e

#
# Copyright (c) 2016, CloudBees, Inc.
#

# 
# Azure ARM setup script to prepare a CJE VM for integration for integration within CJP
#
# usage:
#   setup-master.sh <index_of_master_node> <dns_domain_name> <template_root_url>
#

index=$1
domain=$2
rooturl=$3


# Install licensing plugin
mkdir -p /var/lib/jenkins/plugins
touch /var/lib/jenkins/plugins/cloudbees-license.jpi.pinned
curl $rooturl/cloudbees-license.hpi -o /var/lib/jenkins/plugins/cloudbees-license.jpi
curl $rooturl/client-master-marketplace-licensing.hpi -o /var/lib/jenkins/plugins/client-master-marketplace-licensing.hpi
chown -R jenkins:jenkins /var/lib/jenkins/


CFG="/var/lib/jenkins/com.cloudbees.opscenter.client.plugin.OperationsCenterRootAction.xml"
# Inject openration center connection details
echo "<?xml version='1.0' encoding='UTF-8'?>
<com.cloudbees.opscenter.client.plugin.OperationsCenterRootAction_-DescriptorImpl>
  <state>CONNECTABLE</state>
  <connectionDetails>----- BEGIN CONNECTION DETAILS -----" > $CFG
echo "{
  \"url\": \"http://operations-center-$domain\",
  \"id\": \"$index-jenkins-$index%20(built-in)\",
  \"grant\": \"jenkins-$index\"
}" | gzip -f | base64 >> $CFG
echo "----- END CONNECTION DETAILS -----
</connectionDetails>
  <configurable>true</configurable>
  <registered>true</registered>
</com.cloudbees.opscenter.client.plugin.OperationsCenterRootAction_-DescriptorImpl>
" >> $CFG

chown jenkins:jenkins $CFG


# Configure Jenkins root URL
echo "<?xml version='1.0' encoding='UTF-8'?>
<jenkins.model.JenkinsLocationConfiguration>
  <adminAddress>address not configured yet &lt;nobody@nowhere&gt;</adminAddress>
  <jenkinsUrl>http://jenkins-$index-$domain/</jenkinsUrl>
</jenkins.model.JenkinsLocationConfiguration>"                                      \
> /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml

chown jenkins:jenkins /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml

/etc/init.d/jenkins restart