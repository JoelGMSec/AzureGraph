<p align="center"><img width=600 alt="AzureGraph" src="https://github.com/JoelGMSec/AzureGraph/blob/main/AzureGraph.png"></p>

# AzureGraph
**AzureGraph** is an Azure AD information gathering tool over Microsoft Graph. 

Thanks to Microsoft Graph technology, it is possible to obtain all kinds of information from Azure AD, such as users, devices, applications, domains and much more.

This application, allows you to query this data through the API in an easy and simple way through a PowerShell console. Additionally, you can download all the information from the cloud and use it completely offline.


# Requirements
- PowerShell 4.0 or higher

# Download
It's recommended to clone the complete repository or download the zip file.\
You can do this by running the following command:
```
git clone https://github.com/JoelGMSec/AzureGraph
```


# Usage
```
.\AzureGraph.ps1 -h

     _                         ____                 _
    / \    _____   _ _ __ ___ / ___|_ __ __ _ _ __ | |__
   / _ \  |_  / | | | '__/ _ \ |  _| '__/ _' | '_ \| '_ \
  / ___ \  / /| |_| | | |  __/ |_| | | | (_| | |_) | | | |
 /_/   \_\/___|\__,_|_|  \___|\____|_|  \__,_| .__/|_| |_|
                                             |_|
  -------------------- by @JoelGMSec --------------------


 Info:  This tool helps you to obtain information from Azure AD
        like Users or Devices, using de Microsft Graph REST API

 Usage: .\AzureGraph.ps1 -h
          Show this help, more info on my blog: darkbyte.net

        .\AzureGraph.ps1
          Execute AzureGraph in fully interactive mode

 Warning: You need previously generated MS Graph token to use it
          You can use a refresh token too, or generate a new one

```

### The detailed guide of use can be found at the following link:

https://darkbyte.net/azuregraph-enumerando-azure-ad-desde-microsoft-graph


# License
This project is licensed under the GNU 3.0 license - see the LICENSE file for more details.


# Credits and Acknowledgments
This tool has been created and designed from scratch by Joel Gámez Molina // @JoelGMSec


# Contact
This software does not offer any kind of guarantee. Its use is exclusive for educational environments and / or security audits with the corresponding consent of the client. I am not responsible for its misuse or for any possible damage caused by it.

For more information, you can find me on Twitter as [@JoelGMSec](https://twitter.com/JoelGMSec) and on my blog [darkbyte.net](https://darkbyte.net).


# Support
You can support my work buying me a coffee:

[<img width=250 alt="buymeacoffe" src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png">](https://www.buymeacoffee.com/joelgmsec)
