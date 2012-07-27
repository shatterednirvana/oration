**First,** Get on Windows and install the [Windows Azure SDK for "Other" languages][sdk]. 
Note that any language SDK will work.

  [sdk]: https://www.windowsazure.com/en-us/develop/other/

## Run locally

 1. Install [Python 2.x][] and add the installation directory (e.g. C:\Python27) to your path.

    > To add a directory to your path, click on the Start menu, right click on Computer, and then
    click on Properties > Advanced system settings > Environment Variables. Add or edit an
    environment variable called "PATH" (case insensitive).

  [python 2.x]: http://python.org/download/

 2. In a Windows Azure Command Prompt, run

        cd my\generated\app\directory
        .\run.cmd

Your app will be accessible at <http://localhost:81/>. Try using [rest-client][] to test it.

  [rest-client]: https://github.com/archiloque/rest-client#shell

When you want to shut down the app, go to a Windows Azure Command Prompt and run

    csrun /devfabric:shutdown
    csrun /devstore:shutdown

## Deploy to Azure

 1. If necessary, [create a Storage Account][portal storage].

  [portal storage]: https://manage.windowsazure.com/#Workspace/StorageExtension/storage

 2. Insert your storage account credentials into ServiceDefinition.csdef. Look
    for the following lines:

        <Variable name="AZURE_STORAGE_ACCOUNT_NAME" value="" />
        <Variable name="AZURE_STORAGE_ACCESS_KEY" value="" />

 3. In a Windows Azure Command Prompt, run

        .\pack.cmd

 4. [Create a cloud service][portal service] and upload the service package (.cspkg)
    and service configuration (ServiceConfiguration.Cloud.cscfg).

  [portal service]: https://manage.windowsazure.com/#Workspace/CloudServicesExtension/list

Wait around 10 minutes, and your app will be deployed!
