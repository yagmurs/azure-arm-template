#!/bin/bash

set -x
set -e

#
# Copyright (c) 2016, CloudBees, Inc.
#

#
# Azure ARM setup script to prepare a CJOC VM for integration within CJP
#
# usage:
#   setup-operations-center.sh <index_of_master_node> <dns_domain_name>
#

index=$1
domain=$2


INIT=/var/lib/jenkins-oc/init.groovy.d/oc-init-masters.groovy
curl https://raw.githubusercontent.com/ndeloof/azure-templates/master/oc-init-masters.groovy -o $INIT

sed -i "s/__REPLACE_WITH_MASTERS_COUNT__/$index/" "$INIT"

chown jenkins-oc:jenkins-oc $INIT

# Configure Jenkins root URL
echo "<?xml version='1.0' encoding='UTF-8'?>
<jenkins.model.JenkinsLocationConfiguration>
  <adminAddress>address not configured yet &lt;nobody@nowhere&gt;</adminAddress>
  <jenkinsUrl>http://operations-center-$domain/</jenkinsUrl>
</jenkins.model.JenkinsLocationConfiguration>"                                      \
> /var/lib/jenkins-oc/jenkins.model.JenkinsLocationConfiguration.xml

chown jenkins-oc:jenkins-oc /var/lib/jenkins-oc/jenkins.model.JenkinsLocationConfiguration.xml

/etc/init.d/jenkins-oc restart

