# Global page structure and page content copying
How to copy a complete page tree (used for Customer templates for example)

You will first need to create an API key through the application for this to work.
Here you can find how to create a key: https://docs.requarks.io/dev/api

In the script you replace the text **\<API KEY>** with your key.
Also add your WikiJS url within the: **\<WIKIJSAddress>**

Next you need to set which folder structure to copy in the **$templateParentPath** variable.
  
When all this is done you can trigger the script, but remember changing **$customerName** and **$customerID** each time you run the job!
