#!/bin/bash

set -e

#
# Copyright (c) 2016, CloudBees, Inc.
#

#
# Azure ARM setup script to prepare a CJOC VM for integration within CJP
#
# usage:
#   setup-operations-center.sh <number_of_masters> <dns_domain_name> <template_root_url> <subscriptionId> <adminPassword>
#

masters=$1
domain=$2
rooturl=$3
subscription=$4
adminPassword=$5

INIT=/var/lib/jenkins-oc/init.groovy.d/oc-init-masters.groovy
curl $rooturl/oc-init-masters.groovy -o $INIT
sed -i "s/__REPLACE_WITH_MASTERS_COUNT__/$masters/" "$INIT"
chown jenkins-oc:jenkins-oc $INIT

INIT=/var/lib/jenkins-oc/init.groovy.d/security-realm-azure.groovy
curl $rooturl/security-realm-azure.groovy -o $INIT
sed -i "s/__REPLACE_WITH_PASSWORD__/$adminPassword/" "$INIT"
chown jenkins-oc:jenkins-oc $INIT


# Configure Jenkins root URL
echo "<?xml version='1.0' encoding='UTF-8'?>
<jenkins.model.JenkinsLocationConfiguration>
  <adminAddress>address not configured yet &lt;nobody@nowhere&gt;</adminAddress>
  <jenkinsUrl>http://$domain/</jenkinsUrl>
</jenkins.model.JenkinsLocationConfiguration>"                                      \
> /var/lib/jenkins-oc/jenkins.model.JenkinsLocationConfiguration.xml

chown jenkins-oc:jenkins-oc /var/lib/jenkins-oc/jenkins.model.JenkinsLocationConfiguration.xml

# Configure security
echo "<?xml version='1.0' encoding='UTF-8'?>
<com.cloudbees.opscenter.server.security.SecurityEnforcer_-GlobalConfigurationImpl>
  <global class='com.cloudbees.opscenter.server.sso.SecurityEnforcerImpl' >
    <canOverride>false</canOverride>
    <canCustomMapping>false</canCustomMapping>
    <defaultMappingFactory class='com.cloudbees.opscenter.server.security.TrustedEquivalentRAMF' />
  </global>
</com.cloudbees.opscenter.server.security.SecurityEnforcer_-GlobalConfigurationImpl>"  \
> /var/lib/jenkins-oc/com.cloudbees.opscenter.server.security.SecurityEnforcer\$GlobalConfigurationImpl.xml

chown jenkins-oc:jenkins-oc /var/lib/jenkins-oc/com.cloudbees.opscenter.server.security.SecurityEnforcer\$GlobalConfigurationImpl.xml

echo "Azure Marketplace" > /var/lib/jenkins-oc/.cloudbees-referrer.txt
echo "    subscriptionId: $subscription" >> /var/lib/jenkins-oc/.cloudbees-referrer.txt

/etc/init.d/jenkins-oc restart

