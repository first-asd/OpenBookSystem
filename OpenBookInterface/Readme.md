#Open Book UI Website

##Requirements:
Visual Studio 2013 Professional and IIS 6.0 or later are required. 
The web site is APS.NET MVC application. For more details how to setup IIS for MVC applications see here:
http://blogs.msdn.com/b/rickandy/archive/2011/04/22/test-you-asp-net-mvc-or-webforms-application-on-iis-7-in-30-seconds.aspx
http://www.asp.net/mvc/overview/deployment/visual-studio-web-deployment/deploying-to-iis

##Installation and Configuration
##1. Step One: Publish the web site.
Open the project in Visual Studio and rright click on the project in Solution Explorer; choose Publish.
![](https://raw.githubusercontent.com/first-asd/OpenBookSystem/master/OpenBookInterface/readme-files/publish.png)

Follow the wizard (samples are for File System method):
![](https://raw.githubusercontent.com/first-asd/OpenBookSystem/master/OpenBookInterface/readme-files/publish-wiz.png)

In the next two steps choose next.
In the folder that you specified in "Target location" you will find the files needed for deployment.

##2. Step Two: Deploy the web site.
In IIS right click on "Sites" and choose "Add Web Site".
Fill all required fields.
![](https://raw.githubusercontent.com/first-asd/OpenBookSystem/master/OpenBookInterface/readme-files/iis-add.png)

Select "Application Pools" in the list find the application pool that is created for your web site(usually with same name as "Site name") and make sure that it is using .Net Framework v4
Copy all files and folders from "Target location" that you choose in step one.
##3. Configuration
At this point deployment is complete. Make sure that in web.config you have the correct url of the web services.
<system.serviceModel>
    <bindings>
      <basicHttpBinding>
        <binding name="BasicHttpBinding_IOpenBookAPIService" 
closeTimeout="02:00:00" openTimeout="02:00:00" receiveTimeout="02:00:00" sendTimeout="02:00:00" maxBufferPoolSize="2147483647" maxReceivedMessageSize="2147483647">
          <readerQuotas maxDepth="2147483647" maxStringContentLength="2147483647" maxArrayLength="2147483647" maxBytesPerRead="2147483647" maxNameTableCharCount="2147483647" />
        </binding>
      </basicHttpBinding>
    </bindings>
    <client>
      <endpoint address="http://iwebtech.dynalias.com/FIRST/v4_0/OpenBookAPIService.svc" binding="basicHttpBinding" bindingConfiguration="BasicHttpBinding_IOpenBookAPIService" contract="OBISReference.IOpenBookAPIService" name="BasicHttpBinding_IOpenBookAPIService" />
    </client>   
  </system.serviceModel>

#License
Copyright 2014 KODAR OOD
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at:  
http://www.apache.org/licenses/LICENSE-2.0
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: 
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#Warranty
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
