#!/bin/bash

set -e

#
# Copyright (c) 2016, CloudBees, Inc.
#

#
# Azure ARM setup script to prepare a CJOC VM for integration within CJP
#
# usage:
#   setup-operations-center.sh <number_of_masters> <dns_domain_name> <template_root_url>
#


function finish {
  # delete myslef. We don't want to assist people in hacking our licensing stuff
  rm -- "$0"
}
trap finish EXIT

# FIXME refresh VM image ?
apt-get update ; apt-get install -y --only-upgrade walinuxagent

masters=$1
domain=$2
rooturl=$3

# unique ID of this VM
uuid=`dmidecode -s system-uuid`
# Allow jenkins user to run `sudo dmidecode`
echo "jenkins-oc ALL=(ALL) NOPASSWD: /usr/sbin/dmidecode" >> /etc/sudoers.d/dmidecode

apt-get install -y xml2

# Extract licensing metadata from CloudInit config and inject as encrypted file to discourage (bad) hackers
cat /var/lib/waagent/ovf-env.xml | xml2 | sed -n 's/^.*CustomData=//p' | base64 --decode | openssl enc -des3 -k $uuid  -out /var/lib/jenkins-oc/license.des


INIT=/var/lib/jenkins-oc/init.groovy.d/oc-init-masters.groovy
curl $rooturl/oc-init-masters.groovy -o $INIT

sed -i "s/__REPLACE_WITH_MASTERS_COUNT__/$masters/" "$INIT"

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

