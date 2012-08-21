To locally test or deploy your application you'll need the [Windows Azure SDK
for "Other" languages](https://www.windowsazure.com/en-us/develop/other/) (any
language SDK will work, but this one has less stuff). You'll also need a recent
version of Windows (Windows 7 Home and Windows 7 Professional have been
tested).

## Local testing

From a Windows Azure SDK command-line, run:

    .\run.cmd

To shut down the Azure emulators, run:

    csrun /devfabric:shutdown
    csrun /devstore:shutdown

## Configuration

**Important:** before deploying to Azure, you should insert your [Windows Azure
Storage account credentials][windows azure portal] into
`ServiceDefinition.csdef`. Look for the following lines:

    <Variable name="AZURE_STORAGE_ACCOUNT_NAME" value="" />
    <Variable name="AZURE_STORAGE_ACCESS_KEY" value="" />

If you have Waz-Cmd installed (see below), you can get your credentials if you
know your storage acount name:

    waz connection string STORAGE_ACCOUNT_NAME

Otherwise, get them from the [Windows Azure Portal][].

## Deployment

You'll need Windows to package your application for deployment to Azure. From
a Windows Azure SDK command-line, run:

    .\pack.cmd

The package will be called "{{ app_id }}.cspkg" and you can deploy it to Azure
either using the [Windows Azure portal][] or the excelent [Waz-Cmd][]. To use
Waz-Cmd, first [install ruby][] and, from a command-line, run:

  [waz-cmd]: https://github.com/smarx/waz-cmd
  [install ruby]: http://rubyinstaller.org/

    gem install waz-cmd
    was set subscriptionId XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
    waz generate certificates

You'll need your subscription id (from the [Windows Azure portal][]) to replace
`XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` above. Also, the last command will generate 
a management certificate that you'll need to upload to the [Windows Azure
Portal][]. Finally, you can **deploy**:

  [windows azure portal]: http://windows.azure.com/

    waz create application {{ app_id }} "US West"
    waz deploy {{ app_id }} production {{ app_id }}.cspkg ServiceConfiguration.Cloud.cscfg
    
Wait around 10 minutes. Use the following command to check if the deployment is ready:

    waz show deployment {{ app_id }} production --expand

Finally, note that you'll need to delete the deployment before replacing it (or you can use
[VIP swap]):

  [vip swap]: http://msdn.microsoft.com/en-us/library/windowsazure/ee517253.aspx

    waz delete deployment {{ app_id }} production

## Tips

If you are already on a command line session and you don't want to start a new
one to get access to the Windows Azure SDK tools, run (`<Tab>` denotes pressing
the <kbd>Tab</kbd> key on your keyboard):

    run "C:\Program Files\Windows Azure SDK\<Tab>\bin\setenv.cmd"

If you are on PowerShell, you should run the following instead (or add it to
your profile). Note that you might need to update "v1.6" with your SDK version.

    $azureEmulator = $env:WindowsAzureEmulatorInstallPath = "C:\Program Files\Windows Azure Emulator"
    $azureSDK = $env:ServiceHostingSDKInstallPath = "C:\Program Files\Windows Azure SDK\v1.6\bin"
    $env:path += ";$azureSDK;$azureEmulator\emulator\;$azureEmulator\emulator\devstore\"
