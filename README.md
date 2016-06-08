# CloudBees Jenkins Platform on Azure ARM

Deploy CJOC and a set of CJE masters on Azure using ARM template.

## setup

Template do run installation scripts to prepare the instances.
It relies on fixed private IPs (`10.0.0.100+`) to pre-configure CJOC with connected masters.
shell script do create the required xml configuration on jenkins oc and masters.

## Licensing

[Marketplace Licenseing plugin](https://github.com/cloudbees/marketplace-licensing-plugin) is used
to generate a dynamic lisence. As azure does not (yet) offer a metadata API, we rely on
injecting license details during provisionning, then encrypt using instance UUID. This
results in a binary file in JENKKINS_HOME, harder to hack.

## References

* ARM templates samples https://github.com/Azure/azure-quickstart-templates
* Azure Marketplace requirement https://github.com/Azure/azure-marketplace/
* Draft Marketplace best practices https://drive.google.com/open?id=0BywtocVIFJEDWjg1d2ZWM3UwV2M

## How to test

One can't test the full template deployment (need to publish, get certified, then push to staging)
But on can test the technical ARM template and the UI definition using those links :

### UI definition

UI definition can be tested from last commit on github using : 

<a href='https://portal.azure.com/#blade/Microsoft_Azure_Compute/CreateMultiVmWizardBlade/internal_bladeCallId/anything/internal_bladeCallerParams/{"initialData":{},"providerConfig":{"createUiDefinition":"https%3A%2F%2Fraw.githubusercontent.com%2Fcloudbees%2Fazure-arm-template%2Fmaster%2FcreateUiDefinition.json"}}' target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### ARM Template

Use browser development tools to capture the UI definition JSON output. Store in `parameters.json`, edit if necessary

Create a resource group `test123`, then run
 
```
azure group deployment create test123 --template-file mainTemplate.json --parameters-file parameters.json
```


Can also run the template with some UI definition from last commit on github using : 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcloudbees%2Fazure-arm-template%2Fmaster%2FmainTemplate.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


