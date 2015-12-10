/*
 *  Copyright (c) 2016, CloudBees, Inc.
 */

import com.cloudbees.opscenter.server.model.ClientMaster;
import com.cloudbees.opscenter.server.properties.ConnectedMasterLicenseServerProperty;

import jenkins.model.Jenkins

Jenkins jenkins = Jenkins.instance

def masters = __REPLACE_WITH_MASTERS_COUNT__
masters.times {
    def name = "jenkins-$it (built-in)"
    if (jenkins.getItem(name) == null) {
        String grantId = "jenkins-$it"
        ClientMaster cm = jenkins.createProject(ClientMaster.class, name);
        cm.setId(it)
        cm.setGrantId(grantId);
        cm.getProperties().replace(new ConnectedMasterLicenseServerProperty(new ConnectedMasterLicenseServerProperty.FloatingExecutorsStrategy()));
        cm.save();
    }

}
