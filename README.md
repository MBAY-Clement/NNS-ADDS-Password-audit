# NSS - ADDS Password Quality Control

<p align="center">
  <img src="https://github.com/user-attachments/assets/4c344406-a671-462a-8367-26ea2b85abac" alt="NNS-logo"/>
</p>
<br>

> [!IMPORTANT]
>In this first version, NSS is available only in French (logs, comments in the script,report, etc, are in French).
<div >
    <img src="https://camo.githubusercontent.com/946082f2606913f2cbdf6dc3fdaf466ebee3dfdd27d0b171d7ed8fd34dc2718a/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f506f7765725368656c6c2d3325323025374325323034253230253743253230352d3030303046462e7376673f6c6f676f3d506f7765725368656c6c" alt="PowerShell 3 | 4 | 5" data-canonical-src="https://img.shields.io/badge/PowerShell-3%20%7C%204%20%7C%205-0000FF.svg?logo=PowerShell">
    <img src="https://camo.githubusercontent.com/fa00540bee7cf28bb96d38201d5baacedf8fcd5a7f41388541ed4748170811d2/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f57696e646f77732532305365727665722d323030382532305232253230253743253230323031322532305232253230253743253230323031362532302537432532303230313925323025374325323032303232253743253230323032352d3030376262382e7376673f6c6f676f3d57696e646f77732532303131" alt="Windows Server 2008 R2 | 2012 R2 | 2016 | 2019 | 2022 | 2025" data-canonical-src="https://img.shields.io/badge/Windows%20Server-2008%20R2%20%7C%202012%20R2%20%7C%202016%20%7C%202019%20%7C%202022%7C%202025-007bb8.svg?logo=Windows%2011">
</div>
<br>

**Not Need Speco**** is a PowerShell script for auditing password quality in your AD DS !

The purpose of this script is to audit the password quality of the users in your Active Directory. Regularly auditing the passwords in your Active Directory is an essential practice for strengthening the security of your environment. By identifying weak, common, or compromised passwords, you can prevent unauthorized access and significantly reduce the risk of system compromise. Additionally, this approach helps raise awareness among users about the importance of choosing strong passwords, thereby contributing to overall better security hygiene.

# 💡 What it can do ?

The script in its first version allows you to:

- Detect accounts with passwords listed in a defined wordlist.
- Detect accounts with the same password.
- Detect accounts with passwords that never expire, including critical accounts with passwords that never expire.

In the "Raw Report" button on the homepage, you will find additional audit results (e.g., the list of accounts without passwords). However, these options are not yet visible in the final revised version accessible from the homepage.

By default, the audit only runs on active accounts in your AD. However, you can add an option to also scan disabled accounts.


# 📚 Script Structure

This script is divided into several "sub-scripts" and folders. It is crucial not to modify the directory structure or file names. Once the configuration is complete (see below), the only script to run is `1-main.ps1`.

![image](https://github.com/user-attachments/assets/3d870e78-f537-4f49-a00c-f0011aac5759)

Explanation of Each Script/Folder :

- **`Historique scan`**: Once the audit is complete, the .zip file containing the HTML audit report is moved to this folder. If an audit has already been performed on the same day, the .zip file will not be moved and will remain in the current folder.
- **`temp`**: Folder required for the proper functioning of the script.
- **`1-main.ps1`**: The main file, the only one to run to start the audit.
- **`2-lancement-audit.ps1`**: Script that executes the audit.
- **`3-fichiertxt.ps1`**: Script used for the final report.
- **`4-decoupage.ps1`**: Script used for the final report.
- **`5-structuration-txt.ps1`**: Script used for the final report.
- **`6-export-zip.ps1`**: Script that places the final report into a password-protected zip file.

**`logs-audit-passwd-ad.txt`**: This file contains logs generated during each audit run and throughout its duration. It will be useful for identifying the cause of any audit failures.

**`wordlist.txt`**: This file is used to audit and determine if accounts have weak or easily guessable passwords. In the homepage menu, you will find a section called "Find in Wordlist" which lists all accounts with passwords found in this file. You are free to populate this file with passwords of your choice (you can find wordlists on this site: [Weak Pass](https://weakpass.com/)). Note that the larger this file is (i.e., the more passwords it contains), the longer the audit will take.


# 🚨 Prerequisites and Constraints

Here are the prerequisites for running the script:

- Allow the execution of unsigned scripts (you may choose to sign them if you wish).
- It is mandatory to run the script with an AD account that has replication rights and access to the NTDS of your AD.
- We strongly recommend opening the final report (HTML file) on a computer with internet access (a report not requiring internet access will be created soon).

This script works with the help of these Powershell modules :

- [ActiveDirectory](https://learn.microsoft.com/en-us/powershell/module/activedirectory/?view=windowsserver2022-ps)
- [DSInternals](https://github.com/MichaelGrafnetter/DSInternals)
- [7Zip4Powershell](https://www.powershellgallery.com/packages/7Zip4Powershell/2.0.0)

# 🚀 First launch

> [!TIP]
> You'll find at the end of this section a short tutorial video explaining this step.

<br>

In the file `2-lancement-audit.ps1`, on lines 11 and 12, modify the variables to include your AD domain information to be audited. Here is an example :

![image](https://github.com/user-attachments/assets/45a35498-e2f0-4c52-8acf-b4fe4101526f)

In the file `4-decoupage-audit.ps1`, on line 32, add your domain in the format: `"  DOMAINE\"`, making sure to keep the two spaces before entering the domain. Here is an example :

![image](https://github.com/user-attachments/assets/af90e5a6-6732-4d87-b921-5e9118db7154)

In the file `6-export-zip.ps1`, on line 37, we recommend entering the desired password to encrypt the .zip file containing the final audit report.

![image](https://github.com/user-attachments/assets/601a0365-09d6-4d9d-acf5-9d30115d8041)
Please note that the password is currently stored in plain text in the script 🫨.
<br>

https://github.com/user-attachments/assets/576b30bd-78aa-4ee3-af19-97e0d124b06b

# 📋 Report 
> [!NOTE]
> In the next version, the report will be available in English.

<br>
This script generates a report titled 'Rapport Audit Password.
In this first version of the script, we recommend opening the report with an internet connection. This report was generated with the help of Bootstrap.
<br><br>


You can find a demo report here: [mbay.fr/nns](https://mbay.fr/nns)

![image](https://github.com/user-attachments/assets/db1899f6-ed9a-4d84-ae94-546fb2e84e3d)

# 📈 Future Goals for NNS

The future goal of NNS is to grow. Here are the planned improvements:

- Fully local audit report.
- Redesign of table formats.
- Addition of a graphical user interface.
- Introduction of new options.
- English version.
- ...

# ⚖️ Disclaimer

We disclaim all responsibility for how you might use this script.

This script was developed in response to a real need in the professional field. We do not claim to be programming experts, and this script was created with passion. We are aware that it can be significantly improved and optimized.

This script is licensed under [CC BY-NC-SA](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.fr).

# Contact
If you have any questions, suggestions, or feedback regarding this project, please feel free to reach out. 
You can contact me through the following channels : 

- Website : [mbay.fr](https://mbay.fr/)
- Discord : mbayclement






