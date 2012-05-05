**Wait! You are still not done!**

## Configuration

Before deploying to Azure, you should insert your [Windows Azure Storage credentials][windows azure portal] into `ServiceDefinition.csdef`. Look for the following lines:

    <Variable name="AZURE_STORAGE_ACCOUNT" value="" />
    <Variable name="AZURE_STORAGE_SECRET_KEY" value="" />

## Local testing

Just run the following from a Windows Azure SDK command-line (or just run `run Program Files\Windows Azure SDK\<version>\bin\setenv.cmd` in an existing command line):

    .\run.cmd

## Deployment

I recommend the excelent [Waz-Cmd](https://github.com/smarx/waz-cmd). First, [install ruby](http://rubyinstaller.org/) and run:

    gem install waz-cmd
    waz generate certificates
    was set subscriptionId XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

You can get your subscrition id from the [Windows Azure portal][]. Then upload the management certificate in the [Windows Azure portal][].

  [windows azure portal]: http://windows.azure.com/

From a Windows Azure SDK command-line (or just run `run Program Files\Windows Azure SDK\<version>\bin\setenv.cmd` in an existing command line), run the following:

    .\pack.cmd
    waz deploy {{ app_id }} staging {{ app_id }}.cspkg ServiceConfiguration.Cloud.cscfg

Yay!
