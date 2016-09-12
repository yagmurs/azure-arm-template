/*
 *  Copyright (c) 2016, CloudBees, Inc.
 */


import hudson.BulkChange
import hudson.security.FullControlOnceLoggedInAuthorizationStrategy
import hudson.security.HudsonPrivateSecurityRealm
import jenkins.model.Jenkins

import static hudson.security.AuthorizationStrategy.UNSECURED
import static hudson.security.SecurityRealm.NO_AUTHENTICATION

import org.apache.commons.codec.binary.Base64;


File markerFile = new File(Jenkins.getInstance().getRootDir(), ".azure-security-configured")
if (markerFile.exists()) {
    println "[azure-security-realm] Security already configured, skipping"
    return;
}

def jenkins = Jenkins.getInstance()
BulkChange bulkChange = new BulkChange(jenkins)
try {

    // Set security realm to User Database, with sign-up disabled.
    def realm = new HudsonPrivateSecurityRealm(false, false, null)
    realm.createAccount("admin", new String( Base64.decodeBase64("__REPLACE_WITH_PASSWORD__") ))
    jenkins.setSecurityRealm(realm)

    // User can do anything when logged in - including change security settings.
    jenkins.setAuthorizationStrategy(new FullControlOnceLoggedInAuthorizationStrategy())

    bulkChange.commit()
    println "[azure-security-realm] Jenkins has been secured, can login as 'admin' and password set from ARM template"

} catch (Exception e) {
    bulkChange.abort()
    println "[azure-security-realm] Jenkins configuration changes aborted due to " + e
    e.printStackTrace(System.out)
} finally {
    // this script is intended to run on a "blank" jenkins configuration. Disable it even if an exception occurred
    try {
        markerFile.createNewFile()
    } catch (Exception e) {
        println "[azure-security-realm] Exception creating $markerFile :"+ e
    }
}