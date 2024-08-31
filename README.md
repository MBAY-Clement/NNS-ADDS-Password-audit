# NSS - ADDS Password Quality Control

<p align="center">
  <img src="https://github.com/user-attachments/assets/08d71f9e-65ed-412a-ae9b-55357ce99028" alt="NNS-logo"/>
</p>
<br>

Not Need Speco** is a PowerShell script for auditing password quality in your AD DS !

The purpose of this script is to audit the password quality of the users in your Active Directory. Regularly auditing the passwords in your Active Directory is an essential practice for strengthening the security of your environment. By identifying weak, common, or compromised passwords, you can prevent unauthorized access and significantly reduce the risk of system compromise. Additionally, this approach helps raise awareness among users about the importance of choosing strong passwords, thereby contributing to overall better security hygiene.

# What it can do ?

The script in its first version allows you to:

- Detect accounts with passwords listed in a defined wordlist.
- Detect accounts with the same password.
- Detect accounts with passwords that never expire, including critical accounts with passwords that never expire.

In the "Raw Report" button on the homepage, you will find additional audit results (e.g., the list of accounts without passwords). However, these options are not yet visible in the final revised version accessible from the homepage.

By default, the audit only runs on active accounts in your AD. However, you can add an option to also scan disabled accounts.


# Script Structure

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


# Prerequisites and Constraints

Here are the prerequisites for running the script:

- Allow the execution of unsigned scripts (you may choose to sign them if you wish).
- It is mandatory to run the script with an AD account that has replication rights and access to the NTDS of your AD.
- We strongly recommend opening the final report (HTML file) on a computer with internet access (a report not requiring internet access will be created soon).

# First launch

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

# Repport 
> [!NOTE]
> In the next version, the report will be available in English.

<br>
This script generates a report titled 'Rapport Audit Password.

You can find a demo report here: [mbay.fr/nss](https://mbay.fr/nss)

![image](https://github.com/user-attachments/assets/db1899f6-ed9a-4d84-ae94-546fb2e84e3d)

# Future Goals for NNS

The future goal of NNS is to grow. Here are the planned improvements:

- Fully local audit report.
- Redesign of table formats.
- Addition of a graphical user interface.
- Introduction of new options.
- English version.
- ...

# Disclaimer

We disclaim all responsibility for how you might use this script.

This script was developed in response to a real need in the professional field. We do not claim to be programming experts, and this script was created with passion. We are aware that it can be significantly improved and optimized.

This script is licensed under [CC BY-NC-SA](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.fr).





