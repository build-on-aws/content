---
title: "Set Up and Configure Microsoft PKI for Smart Card Authentication with Amazon WorkSpaces"
description: "A comprehensive guide on configuring Microsoft PKI and AWS infrastructure to support smart card authentication for your Amazon WorkSpaces."
tags:
  - workspaces
  - directory-service
  - piv-authentication
  - microsoft-pki
  - tutorials
  - active-directory
authorGithubAlias: austinwebber
authorName: Austin Webber
date: 2023-06-23
---

Amazon WorkSpaces provides customers with the ability to use Common Access Card (CAC) and Personal Identity Verification (PIV) smart cards for authentication into WorkSpaces. Amazon WorkSpaces supports the use of smart cards for both pre-session authentication (authentication into the WorkSpace) and in-session authentication (authentication that's performed after logging in). For example, your users can login to their WorkSpaces using smart cards and they can use their smart cards in within their WorkSpace session to authenticate to websites or other applications. Pre-session smart card authentication requires an _Active Directory Connector_ connected to _AWS Microsoft Managed AD_ or self-managed AD, Online Certificate Status Protocol (OCSP) for certificate revocation checking, Root CA and smart card certificates with certain requirements, a CAC or PIV smart card, a version of the WorkSpaces client that supports smart card authentication, and a WorkSpace assigned to the user that is using a protocol that supports smart card authentication.

In this post, we will walk through step-by-step how you can setup and configure new or existing Microsoft PKI to support smart card authentication including setting up an OCSP  responder, proper configuration of Active Directory, domain controllers, certificate templates, Group Policy, and Amazon WorkSpaces. You can expect to have a fully functioning WorkSpaces smart card authentication environment for both Linux and Windows WorkSpaces after completing the steps in this post.

![High-level architecture overview of the connectivity process to Amazon WorkSpaces using a smart card](./images/01_high-level-architecture-connectivity-process-amazon-workspaces-with-smart-card.png)

[WorkSpaces smart card authentication](https://docs.aws.amazon.com/workspaces/latest/adminguide/smart-cards.html?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq) is supported in the [following regions](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/ad_connector_clientauth.html?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq) at this time:

* Asia Pacific (Sydney)
* Asia Pacific (Tokyo)
* Europe (Ireland)
* AWS GovCloud (US-East)
* AWS GovCloud (US-West)
* US East (N. Virginia)
* US West (Oregon)

| Attributes                |                                   |
| ------------------- | -------------------------------------- |
| ✅ AWS Level        | Advanced - 300                         |
| ⏱ Time to complete  | 45 minutes                             |
| 💰 Cost to complete | USD 1.01      |
| 🧩 Prerequisites    | - [AWS Account](https://aws.amazon.com/resources/create-account/?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq)<br>- CAC or PIV card used for smart card authentication  <br> - If you have more than one requirement, add it here using the `<br>` html tag|
| 💻 Code Sample         | Code sample used in tutorial on [GitHub](<link if you have a code sample associated with the post, otherwise delete this line>)                             |
| 📢 Feedback            | <a href="https://pulse.buildon.aws/survey/DEM0H5VW" target="_blank">Any feedback, issues, or just a</a> 👍 / 👎 ?    |
| ⏰ Last Updated     | 2023-06-23                             |

|ToC|
|---|

## Prerequisites

For this walkthrough, you should have the following prerequisites:

* A VPC with at least 2 private subnets (with internet access) and 1 public subnet (with internet access)
* Two Active Directory (AD) domain controllers in different private subnets (if using on-premises AD, ensure VPC connectivity to on-premises is already setup)
* An AD Connector configured to use those domain controllers (including the credentials to your AD Connector service account)
* A EC2 Windows instance joined to the AD domain (referred to as the MGMT EC2 instance in this blog)
* A CAC or PIV card used for smart card authentication
* (Recommended) A public domain in Route53 or a public domain in another provider using a top-level domain found in the _IANA Root Zone Database_ to host a DNS record for the OCSP (Online Certificate Status Protocol) responder instance

## Deploy the solution

The solution I present here involves the following steps:

1. Deploy Microsoft PKI Quick Start template and setup OCSP responder (required if you do not have PKI already setup in your AD environment)
2. Create objects in Active Directory with necessary permissions
3. Configure the Certificate Authority to allow certificates to be issued to smart card users
4. Request a certificate for your individual smart card user
5. Verify the smart card is working with its certificate properly and test that the certificate can be verified with OCSP
6. Register AD Connector with WorkSpaces, create a test Windows WorkSpace using WorkSpaces Streaming Protocol (WSP), import the WSP GPO template, and enable smart card redirection on WorkSpaces
7. Configure the AD Connector to use smart card authentication
8. Test pre-session smart card authentication on Windows WorkSpaces
9. Test in-session smart card authentication on Windows WorkSpaces
10. Setup smart card authentication on Linux WorkSpaces (GovCloud only)
11. Test smart card authentication on Linux WorkSpaces (GovCloud only)

## Section 1: Deploy an offline root CA and enterprise subordinate CA by using the Microsoft Public Key Infrastructure Quick Start template and setup an OCSP responder

If you do not already have Microsoft PKI infrastructure setup (e.g. CAs, OCSP responder), this first section is to deploy an offline root CA and enterprise subordinate CA by using the Microsoft Public Key Infrastructure Quick Start template and create an OCSP responder instance. If you already have PKI infrastructure setup including an OCSP responder, please skip to Section 2.

### Step 1. Create a Secret in Secrets Manager

In this step, you store the AD account credentials used for deploying the template in a Secrets Manager secret. Automation uses this secret to create the CA infrastructure in your self-managed AD environment. This user account should be in the Enterprise Admins group.

1. In the [Secrets Manager console](https://console.aws.amazon.com/secretsmanager/?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq), choose **Store a new secret**.
2. On the **Store a new secret page**, under **Select secret type**, choose **Other type of secret**.
3. Under **Key/value pairs**, do the following:
    1. In the first field, enter `username`, and in the same row, in the next field, enter the name of your AD account.
    2. Choose **+ Add row**.
    3. On the new row, in the first field, enter `password`, and on the same row, in the next field, enter the password for your AD account.
    4. Under **Encryption key**, choose a key of your choice.
    5. Choose **Next**.
4. On the **Store a new secret page**, for **Secret name**, enter a name for the secret, leave the default settings for the remaining fields, and choose **Next** on each of the next two pages.
5. Review the settings, and then choose **Store** to save your changes. The Secrets Manager console returns you to the list of secrets in your account with your new secret included in the list.
6. Choose your newly created secret from the list, and take note of the **Secret ARN** value. You will need it in the next section.

### Step 2: Deploy the Microsoft Public Key Infrastructure Quick Start template

In this step, you deploy an offline root CA and an enterprise subordinate CA by using the Microsoft Public Key Infrastructure Quick Start. Because you use a Quick Start template for this deployment, you only need to enter the following information—you can change the default values for any fields not explicitly mentioned here.

To deploy the CAs with the Microsoft Public Key Infrastructure Quick Start

1. In the AWS CloudFormation console, choose Create stack and then do the following:
    1. For **Prepare template**, select **Template is ready**.
    2. For **Template source**, select **Amazon S3 URL**.
    3. For **Amazon S3 URL**, enter:  `https://aws-quickstart.s3.amazonaws.com/quickstart-microsoft-pki/templates/microsoft-pki.template.yaml`
    4. Choose **Next**.
2. Specify the stack details as follows:
    1. For **VPC CIDR**, enter the CIDR of the VPC where your self-managed AD directory resides.
    2. For **VPC ID**, select the VPC where your self-managed AD directory resides.
    3. For **CA(s) Subnet ID**, select a subnet in the VPC where your self-managed AD directory resides.
    4. For **Domain Members Security Group ID**, select an existing security group that allows communication with the self-managed AD directory.
    5. For **Key Pair Name**, select an EC2 key pair in your account.
    6. For **Active Directory Domain Services Type**, select **SelfManaged** or **AWSManaged** (dependent on your AD environment).
    7. For **Domain FQDN DNS Name**, enter the DNS name of the AD domain. In this example, I use `corp.example.com`.
    8. For **Domain NetBIOS Name**, enter the NetBIOS name of the AD domain. In this example, I use `CORP`.
    9. For **IP used for DNS (Must be accessible)**, enter the IP address of one of the AD domain controllers.
    10. For **IP used for DNS (Must be accessible)**, enter the IP address of the other AD domain controller.
    11. For **Secret ARN Containing CA Install Credentials**, enter the Secrets Manager secret ARN created in **Step 1: Create Secret in Secrets**.
    12. For **CA Deployment Type**, select **One-Tier** or **Two-Tier**.
    13. For **Use S3 for CA CRL Location**, select **No** or **Yes**.
        1. Note: if you don’t want to use an S3 bucket to store the CRLs, set **Use S3 for CA CRL Location** to **No**. When **No** is selected, the Quick Start stores and hosts the CRLs in a file share and _Internet Information Services (IIS)_ website on the enterprise CA.
    14. For **CA CRL S3 Bucket Name**, enter the name of the bucket created in Step 2: Set up S3 bucket to store certificate revocation lists (CRLs) and certificates.
        1. Note: if you set **Use S3 for CA CRL Location** to **No**, leave this field as default.
    15. Select **Next** on the current screen and the following screen.
    16. Check the box next to each of the following statements.
        1. **I acknowledge that AWS CloudFormation might create IAM resources with custom names.**
        2. **I acknowledge that AWS CloudFormation might require the following capability: CAPABILITY_AUTO_EXPAND.**
    17. Choose **Create stack**.  
![A prompt showing that you need to acknowledge additional capability before deploying the CloudFormation stack](./images/02-additional-capability-before-deploying-cloudformation-stack.png)
It should take 20 to 30 minutes for the resources to deploy.

### Step 3: Allow the domain controllers to communicate with the Enterprise CA

In this step, you configure AWS security group rules so that your directory domain controllers can connect to the enterprise subordinate CA to request a certificate. To do this, you must add outbound rules to each domain controller’s AWS security group to allow all outbound traffic to the AWS security group of the enterprise subordinate CA so that the directory domain controllers can connect to the enterprise subordinate CA to request a certificate. If you are using **self-managed AD** and your domain controllers are outside of AWS, you can ensure your domain controllers allow the necessary traffic from on-premises to the enterprise subordinate CA instance.

1. In the navigation pane of the _AWS VPC console_, under the **Security** heading, choose **Security Groups**.
2. Select the AWS security group of your AWS Managed Microsoft AD directory or a different security group if using self-managed AD. When using AWS Managed Microsoft AD, the security group name is formatted like the following: `d-1234567890_controllers`.
3. Switch to the **Outbound rules** tab, and choose **Edit outbound rules**.
4. Choose **Add rule** and then do the following:
   * For **Type**, select **Custom TCP**.
   * For **Port range**, enter `135`.
   * For **Destination**, select **Custom** and then enter the private IP assigned to the enterprise CA instance.
5. Add another rule:
   * For **Type**, select **Custom TCP**.
   * For **Port range**, enter `49152 - 65535`.
   * For **Destination**, select **Custom** and then enter the private IP assigned to the enterprise CA instance.
6. Choose **Save rules**.

The domain controllers will automatically request a certificate based on the template named **LdapOverSSL-QS** that was created by the Microsoft Public Key Infrastructure on AWS Quick Start deployment. It can take up to 30 minutes for the directory domain controllers to auto-enroll the available certificates.

### Step 4: Setup domain controller auto-enrollment for certificates

As the CloudFormation template creates and deploys a certificate template named **LdapOverSSL-QS**, ensure your domain controllers have auto-enrollment enabled in order for them to be granted a certificate to be used for authenticating users. Each domain controller that is going to authenticate smart card users **must have** a domain controller certificate. If you are using **AWS Microsoft Managed AD**, you can skip this step.

1. Connect to your MGMT instance with an AD user in the Domain Admins or AWS Delegated Administrators group.
2. Open PowerShell as an Administrator and run the following commands to install the Group Policy Management console if it's not installed and open it:

```powershell
Install-WindowsFeature GPMC
gpmc.msc
```

1. Create or locate an existing group policy in your domain, right-click it, select **Edit…**
2. Enable certificate auto-enrollment in the policy:
    * In the Group Policy Management Editor, under **Computer Configuration**, and expand **Policies**.
    * Expand **Windows Settings**, expand **Security Settings**, and select **Public Key Policies.**
    * Double-click **Certificate Services Client – Auto-Enrollment** and set the following settings:  
![Image showing the configuration that you need to enable in Auto-Enrollment for the Certificates Service Client. Enable "Renew expired certificates..." and "Update Certificates that use certificate templates"](./images/03-auto-enrollment--certificates-service-client.png)
    * After applying the setting, close out of Group Policy Management Editor.

### Step 5: Confirm the domain controllers contain required certificates

Ensure the domain controllers have a certificate in their Personal store from the certificate template **LdapOverSSL-QS**. Each domain controller that is going to authenticate smart card users **must have** a domain controller certificate.

Review the certificate store on each domain controller to ensure they receive a certificate from the **LdapOverSSL-QS** template:

1. On the MGMT instance, open **certlm.msc**.
2. Right-click **Certificates – Local Computer**, select **Connect to Another Computer**, enter the name of one of the DCs, select **OK**.
3. Expand **Personal**, select **Certificates**, and confirm a certificate exists from the **LdapOverSSL-QS** template:  
![Image showing the Personal certificate store on a domain controller, which shows an existing certificate in its certificate store](./images/04-personal-certificate-store.png)
4. Repeat the above steps for the remaining domain controllers.

### Step 6: Deploy an EC2 Windows instance and configure it as an OCSP responder instance

For pre-session authentication into WorkSpaces, Online Certificate Status Protocol (OCSP) is required for certificate revocation checking. An OCSP responder is a component of a public key infrastructure (PKI) that can be installed on Windows Server to meet this requirement. The OCSP responder is required to be publicly accessible on the internet over HTTP. In this blog post, we are only setting up one OCSP responder, which we will refer to as the OCSP instance. If you’d like to make the OCSP responder highly available, you can do so by setting up _multiple OCSP responders in an Array_.

1. **Launch a standard EC2 Windows instance** using Windows Server in a public subnet (OCSP responder should be in a public subnet) and set **Auto-assign public IP** to **enable**.
2. Attach a security group to the OCSP instance that allows you to **RDP (port 3389)** into it.
3. [Allocate an Elastic IP](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq) and [associate the Elastic IP](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq) with the EC2 instance.
4. Gather a public DNS name that resolves to the public IP address of your EC2 instance for use later when setting the OCSP responder URL:
    * Option 1: (Recommended) If you own a public domain in Route53 or another provider, [create an A record](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-creating.html?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq) that resolves to the IP address of the OCSP instance. Note down the full DNS name of this record (e.g. ocsp.mydomain.com) as you will need it in the following steps when configuring the CA for OCSP.
    * Option 2: If you do not own a public domain, you can instead use the [auto-generated public IPv4 DNS name](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq) of your EC2 instance. You can find this value in the details tab of your EC2 instance in AWS console. Note down the value of the **Public IPv4 DNS** name for the following steps when configuring the CA for OCSP. If this value does not appear, please ensure **DNS hostnames** is enabled on your VPC.
    * **Note:** If using a DNS name, it must use a top-level domain found in the _Internet Assigned Numbers Authority (IANA) Root Zone Database_.
5. [Manually domain join](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/join_windows_instance.html?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq) the OCSP instance to your AD domain, specify a desired computer name (e.g. OCSP), and restart it.
6. Connect to your Enterprise CA instance (created from the Quick Start template) with an AD user in the Domain Admins or AWS Delegated Administrators group.
7. Duplicate a new OCSP response signing certificate template:
    * Open **certtmpl.msc**, find **OCSP Response Signing** template, right-click it, select **Duplicate Template**.
    * Select the **General** tab, give it a name (e.g. CA OCSP Response Signing), and check **Publish certificate in Active Directory**.  
![Image showing the settings you need to change in the "General" tab of the new Certificate Template you are creating](./images/05-general-tab-certificate-template.png)
    * Select **Security** tab, select **Add…**, select **Object Types…**, check **Computers**, select **OK**.  
![Image showing the object types you need to add when searching](./images/06-object-types-for-searching.png)
    * Enter the computer name of your OCSP instance, select **OK**.
    * For the computer you just added, under **Allow** column, check both **Read** and **Enroll**, select **OK**.  
![Image showing an example of adding Read and Enroll permissions to a specific computer object in the Security tab of this new Certificate Template](./images/07-adding-read-enroll-permissions.png)
8. Publish your certificate template (e.g. CA OCSP Response Signing) and set the OCSP URL on your CA:
    * Open **certsrv.msc**, expand the underlying CA.
    * Right-click **Certificate Templates**, hover over **New**, select **Certificate Template to Issue**.
    * Select your certificate template (e.g. CA OCSP Response Signing), select **OK**.  
![Image showing the dialog box when publishing a sample Certificate Template](./images/08-publishing-sample-certificate-template.png)
9. Set the OCSP URL on your CA:
    * Under **Certification Authority (Local)**, right-click the underlying CA (e.g. ENTCA1), select **Properties**, select **Extensions** tab.
    * Under **Select extension:**, change to **Authority Information Access (AIA)**, select **Add…**
    * For **Location:** enter the URL that includes the DNS name you noted previously in Step 4 above with /ocsp at the end: `http://ocsp.mydomain.com/ocsp`  
![Image demonstrating adding a OCSP URL into the CA ](./images/09-adding-OCSP-url-into-ca.png)
    * Select **OK**, check the box **Include in the online certificate status protocol (OCSP) extension**.  
![Image showing the properties on the CA and specifically the new OCSP URL you added and a checkbox "Include in the OCSP extension" that you need to check](./images/10-properties-on-CA.png)
    * Select **OK**, select **Yes** when prompted to restart the AD CS service for the changes to take effect.
    * **Note:** AD Connector **requires an HTTP URL** for the OCSP responder URL.
10. Connect to your OCSP instance and install the OCSP responder:
    * Connect to your OCSP instance with an AD user in the Domain Admins or AWS Delegated Administrators group.
    * Open PowerShell as Administrator and run the following commands to install the OCSP responder:  

      ```powershell
      Import-Module ServerManager
      Add-WindowsFeature Adcs-Online-Cert
      Install-AdcsOnlineResponder
      Install-WindowsFeature RSAT-Online-Responder
      ```

11. Configure OCSP after installation:
    * Open **ocsp.msc**, right-click **Revocation Configuration**, select **Add Revocation Configuration**.
    * Select **Next**, enter a name (e.g. OCSP), select **Next**, select **Select a certificate for an Existing enterprise CA**, select **Next**.  
![Image showing the "Select CA Certificate Location" step in the "Add Revocation Configuration" wizard](./images/11-Select-CA-Certificate-Location.png)
    * Select **Browse CA certificates published in Active Directory**, select **Browse…**  
![Image showing the "Choose CA Certificate" step in the "Add Revocation Configuration" wizard](./images/12-Choose-CA-Certificate-Add-Revocation-Configuration-wizard.png)
    * Select your CA, select **OK**  
![Image showing the dialog box that allows you to select a Certification Authority](./images/13-select-a-Certification-Authority.png)
    * Select **Next**, ensure to select the certificate template created earlier.  
![Image showing the "Select Signing Certificate" step in the "Add Revocation Configuration" wizard](./images/14-Select-Signing-Certificate.png)
    * Select **Next**, select **Finish**.
12. Adjust the security group attached to the OCSP instance to allow **HTTP (port 80)** from all **IP addresses** as required for the OCSP responder configuration. To perform certificate revocation checking, the OCSP responder must be internet-accessible.

13. Connect back to the Enterprise CA instance and verify Enterprise PKI status:
    * Connect to your Enterprise CA instance.
    * Open **pkiview.msc**, expand out your CAs, select **Refresh**, left-click your CA
    * The content should look similar to the following (with your correct OSCP URL that you also set on the certificate template earlier):  
![Image showing the OCSP Location #1 as verified in pkivew.msc](./images/15-OCSP-Location-pkivew-msc.png)
**Note:** if the OCSP Location #1 shows any error status, it can be due to your Enterprise CA instance not having internet connectivity and/or the OCSP instance is not allowing HTTP traffic from ALL IPs. The Enterprise CA instance needs internet access to verify that the OCSP location is publicly reachable.

14. The public DNS name for your OCSP instance should be publicly resolvable and should be accessible over HTTP (port 80), therefore, on any computer confirm this:
    * Open PowerShell and run the following command (adjust the command to your configured OCSP DNS name): `tnc ocsp.mydomain.com -port 80`
    * The results should look similar to the following:  
![Image showing sample output of the tnc command against an OCSP URL](./images/16-sample-output-tnc-command-against-OCSP-URL.png)

## Section 2: Create objects in Active Directory with necessary permissions

In this step, we will configure AD objects in your environment to prepare for smart card authentication and setup Kerberos Constrained Delegation on your AD Connector service account.

1. Install RSAT (Remote Server Administration Tools) on the MGMT instance and create AD objects:
    * Connect to your MGMT EC2 instance with an AD user in the Domain Admins or AWS Delegated Administrators group.
    * Once connected, open PowerShell as Administrator and run the following command. When prompted, enter the desired password for the test smart card user and hit enter. This command will create an AD user for your test smart card user and an AD group for the smart card users.  

   ```powershell
   $SmartCardTestUser = "**testuser**"
   $SmartCardUsersGroup = "**Smartcard Users**"
   Install-WindowsFeature RSAT-AD-Tools
   
   $DomainName = ("$env:USERDNSDomain".ToLower())
   $OrganizationalUnitForGroup = Get-ADDomain -Current LocalComputer | Select-Object -Expand UsersContainer
   New-ADGroup -Name $SmartCardUsersGroup -SamAccountName $SmartCardUsersGroup -GroupCategory Security -GroupScope Global -DisplayName $SmartCardUsersGroup -Path $OrganizationalUnitForGroup
   New-ADUser -Name $SmartCardTestUser -AccountPassword (Read-Host -AsSecureString "Enter the desired test account password for $SmartCardTestUser") -OtherAttributes @{'mail'="$SmartCardTestUser@$DomainName";'UserPrincipalName'="$SmartCardTestUser@$DomainName"} -Enabled $true
   Add-ADGroupMember -Identity $SmartCardUsersGroup -Members $SmartCardTestUser 
   ```

2. Use the SetSpn command to set a Service Principal Name (SPN) for your existing AD Connector service account to enable the service account for delegation configuration:
    * Open PowerShell and run the following commands (adjust the variables to specify your service account and any unique SPN):  

   ```powershell
   $ServiceAccount = "**ADConnectorSvc**"
   $UniqueSPNName = "**my/spn**"
   setspn -s $UniqueSPNName $ServiceAccount
   ```

3. Configure the delegation settings on your AD Connector service account to allow [mutual TLS authentication with your AD Connector](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/ad_connector_clientauth.html?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq):
    * Open **dsa.msc**, locate your AD Connector service account, right-click it, select **Properties**
    * Choose the **Delegation** tab, Select the **Trust this user for delegation to specified services only** and **Use any authentication protocol** radio buttons:  
![Image showing the "Delegation" tab on a sample AD user account in dsa.msc](./images/17-Delegation-sample-AD-user-dsa-msc.png)
    * Choose **Add…**, select **Users or Computers**, and add ALL of the domain controllers that the AD Connector service account will be allowed to complete TLS mutual authentication with.
    * Choose **OK** to display a list of available services used for delegation:  
![Image showing the "Add Services" window and highlighting each entry that has a Service Type of "ldap" that are for the Windows Domain Controllers  ](./images/18-Add-Services-window.png)
    * Choose the **LDAP** service type for each Domain Controller, click **OK** and click **OK** to finish the configuration.

## Section 3: Configure the Certificate Authority to allow certificates to be issued to smart card users

1. Create a certificate template to allow self-enrollment smart card logon certificates to your users:
    * Connect to your Enterprise CA with an AD user in the Domain Admins or AWS Delegated Administrators group.
    * Open **certtmpl.msc**, find the **Smartcard Logon** template, right-click it, select **Duplicate Template**.
    * Select the **General** tab, change the **Template display name** to a desired name (e.g. SmartcardWS, you will need this name later).
    * Select the **Request Handling** tab, change **Purpose:** to **Signature and smartcard logon**, and select **Yes** when prompted.  
![Image showing the "Request Handling" tab when creating a new Certificate Template and highlighting the "Purpose:" configuration you need to change](./images/19-Request-Handling.png)
    * Select the **Cryptography** tab, select **Requests must use one of the following providers**, check **Microsoft Base Smart Card Crypto Provider**.  
![Image showing the "Cryptography" tab when creating a new Certificate Template and highlighting the "Requests must use one of the following providers:" setting you need to change](./images/20-Cryptography-tab-creating-new-Certificate-Template.png)
    * Select the **Security** tab and select **Add…**
    * Add a user or group that you want to have the ability to request a smart card certificate (e.g. Smartcard Users AD group that was created earlier), and select **OK**.
    * For the user/group you added, check both **Read** and **Enroll** under the **Allow** column.  
![Image showing the "Security" tab when creating a new Certificate Template and highlighting a sample AD group that was added and granted Read and Enroll permissions](./images/21-Security-tab-when-creating-Certificate-Template.png)
    * Select **OK** to finish the creation of the certificate template

2. Publish the certificate template:
    * Open **certsrv.msc**, expand the underlying CA.
    * Right-click **Certificate Templates**, hover over **New**, select **Certificate Template to Issue**.
    * Select the certificate template you just created, select **OK**.

## Section 4: Request a certificate for your test smart card user

In this section, we will login as the smart card user, confirm the smart card is functioning, request a certificate used for smart card authentication, and load the certificate onto the smart card. Some smart cards may require specific drivers to be installed in order for the smart card to function in Windows.

1. Confirm the smart card is functioning in Windows,
    * Open PowerShell, run the command `certutil -scinfo`, and enter your PIN when prompted.
    * The smart card should report as available for use and no errors should be reported.  
![Image showing a successful sample output of the "certutil -scinfo" command](./images/22-successful-sample-output-certutil-scinfo-command.png)
    **Note**: Some smart cards may require minidrivers to be installed. Please refer to the guidance from the manufacturer of the smart card to configure it for use in Windows.

2. Request a certificate for the smart card test user:
    * Connect to a Windows EC2 instance or computer that is joined to your domain as your test smart card user. **Note:** Ensure to use an RDP client that can redirect the smart card into the remote session. The Microsoft Remote Desktop Client can be used for this purpose.
    * Open **certmgr.msc** while logged in as your test smart card user.
    * Right-click **Personal**, select **All Tasks**, select **Request New Certificate…**
    * Select **Next**, select **Next**, check the box next to your certificate template (e.g. SmartcardWS), select **Enroll**:  
![Image showing the "Request Certificates" window and selecting the "SmartcardWS" template created earlier](./images/23-Request-Certificates-window-selecting-SmartcardWS-template.png)
        **Note:** If you do not see the certificate template, ensure your user has enroll permissions on the certificate template. If the computer does not have the CA certificates installed, the certificate template may not be presented. Complete a group policy update to install the certificates.
    * When prompted, enter in your smart card PIN and complete the certificate request:  
![Image showing a prompt to enter the authentication PIN for the smart card when enrolling a certificate on the smart card](./images/24-prompt-enter-authentication-PIN-the-smart-card.png)
    * The certificate request should succeed:  
![Image showing the successful request of a certificate and successful installation of the certificate onto the smart card](./images/25-successful-request-certificate-successful-installation-certificate-onto-the-smart-card.png)
    **Note:**
        * If you are not prompted to enter your PIN during this process, please ensure your certificate template is setup correctly and that your smart card is functioning.
        * Smart cards can have multiple digital slots. Please ensure your certificate is loaded into the authentication slot in order for Windows smart card authentication to succeed.

## Section 5: Verify the smart card is working with its certificate properly and test that the certificate can be verified with OCSP

1. Verify the smart card is working with its certificate properly:
    * Open **certmgr.msc** while logged in as your test smart card user on a computer with the smart card inserted.
    * Expand **Personal**, select **Certificates** folder, and confirm if you see a certificate appear that is signed by your CA’s certs.  
![Image showing the Personal certificate store of a sample smart card user. It has the certificate we requested, in its certificate store](./images/26-Personal-certificate-store.png)
    * If the certificate appears, delete the certificate (ensure you delete the correct one), and unplug your smart card.
    * If the certificate doesn't appear, unplug your smart card. Plug the smart card back in, click the refresh button in MMC, and the certificate should appear (it may take some time and multiple refreshes).
    * This confirms that the smart card is functioning as expected.

2. Test that the certificate can be verified with OCSP:
    * In **certmgr.msc**, right-click your test user’s certificate, select **All Tasks**, select **Export…**
    * Select **Next**, select **Next,** select **Next** select **Browse…**, save the certificate, select **Finish**, and select **OK**.
    * Open PowerShell and change directory (cd) to the directory where the certificate was exported to, and run the following command against the certificate: `certutil -URL **exportedcertificate**.cer`
    * In the URL Retrieval Tool window that opens, select the **OCSP (from AIA)** radio button.  
![Image showing the "URL Retrieval Tool" window that was opened and highlighting the selection of the radio button "OCSP (from AIA)"](./images/27-URL-Retrieval-Tool.png)
    * Select **Retrieve**, you should see status as **Verified** and the OCSP URL appears.  
![Image showing a successful retrieval in the "URL Retrieval Tool" with an entry showing the status "Verified"](./images/28-URL-Retrieval-Tool-with-an-entry-showing-the-status-Verified.png)
    **Note:** If the above fails after 15 seconds or returns unsuccessful, it's likely that you do not have your CA certificates installed in the local computer store that is completing this test or your OCSP responder is not configured correctly.

## Section 6: Register AD Connector with WorkSpaces, create a test Windows WSP WorkSpace, import the WSP GPO template, and enable smart card redirection on WorkSpaces

In this section, we will register your AD Connector with WorkSpaces, create a test Windows WSP WorkSpace, import the WSP GPO template, and enable smart card direction via Group Policy.

1. [Register your AD Connector](https://docs.aws.amazon.com/workspaces/latest/adminguide/register-deregister-directory.html?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq) with WorkSpaces:
    * Open the [WorkSpaces console](https://console.aws.amazon.com/workspaces/?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq), and choose **Directories** in the navigation pane.
    * Select your AD Connector, choose **Actions**, select **Register**.
    * Select two subnets of your VPC that are not in the same Availability Zone. These subnets will be used to launch your WorkSpaces.
    * Choose **Register**.

2. Create a test Windows WSP WorkSpace:
    * [Launch a WSP WorkSpace](https://docs.aws.amazon.com/workspaces/latest/adminguide/launch-workspace-ad-connector.html?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq) for your test user and wait for it to become available.
    **Note:** Smart card authentication is only supported on WSP Windows and WSP Amazon Linux 2 WorkSpaces at this time.
3. Allow RDP into your WorkSpaces.
4. Import the WSP GPO template:
    * Connect to your test user’s WorkSpace via RDP (it must be in a running state) with an AD user in the Domain Admins or AWS Delegated Administrators group.
    * Open the Start Menu, search for **PowerShell** and open it.
    * Run all of the following commands in the PowerShell window to copy the WSP GPO template to the SYSVOL folder:  

    ```powershell
   $DomainName = ("$env:USERDNSDomain".ToLower())
   New-Item \\$DomainName\SYSVOL\$DomainName\Policies\PolicyDefinitions -ItemType "Directory"
   New-Item \\$DomainName\SYSVOL\$DomainName\Policies\PolicyDefinitions\en-US -ItemType "Directory"
   Copy-Item "C:\Program Files\Amazon\WSP\wsp.admx" \\$DomainName\SYSVOL\$DomainName\Policies\PolicyDefinitions
   Copy-Item "C:\Program Files\Amazon\WSP\wsp.adml" \\$DomainName\SYSVOL\$DomainName\Policies\PolicyDefinitions\en-US
   ```

5. Enable smart card direction via Group Policy on WorkSpaces:
    * Connect to your MGMT instance or a domain controller with an AD user in the Domain Admins or AWS Delegated Administrators group.
    * Create or locate an existing group policy in your domain, right-click it, select **Edit…**
    * In the Group Policy Management Editor, under **Computer Configuration**, expand **Policies**, expand **Administrative Templates**, expand **Amazon**, and select **WSP**.
    * Find **Enable/disable smart card redirection**, right-click it, select **Edit**, select **Enabled**, select **OK**.  
![Image showing the "Group Policy Management" console configuring a sample GPO and highlighting the "Enable/disable smart card redirection" setting we need to configure](./images/29-Group-Policy-Management.png)
    * Close out of Group Policy Management Editor once it has been enabled.
    * Once deployed, reboot the test WorkSpace to update the group policy applied to the WorkSpace.

## Section 7: Configure the AD Connector to use smart card authentication

1. Export all of your CA certificates used in your certificate chain in Base-64 encoded format:
    * Connect to your MGMT instance as your test smart card user.
    * Open **certmgr.msc**, expand **Personal**, and select **Certificates**.
    * Double-click the user certificate, select the **Certification Path** tab.  
![Image showing a smart card user](./images/30-smart-card-user-certificate-and-the-full-certificate-path.png)
    * You will need to export and register every certificate in the certification path (besides the user certificate) with the AD Connector.
    * Expand **Trusted Root Certification Authorities**, and select **Certificates**.  
![Image showing the "Trusted Root Certification Authorities" store and highlighting a sample root certificate in the chain "ORCA1" ](./images/31-Trusted-Root-Certification-Authorities.png)
    * Right-click your root certificate, select **All Tasks**, select **Export…**, select **Next**, select **Base-64 encoded X.509 (.CER)**, and select **Next**.
    * Select **Browse…**, save the certificate, select **Next**, select **Finish**, select **OK**.
    * Repeat the same steps for any intermediate certificate in the **Intermediate Certification Authorities** store.  
![Image showing the "Intermediate Certification Authorities" store highlighting a sample intermediate certificate "ENTCA1"](./images/32-Intermediate-Certification-Authorities.png)
    * Copy the outputted Base64 certificate(s) to your local computer or a computer with access to AWS console.

2. Register the outputted certificates with your AD Connector:
    * Open [Directory Services console](https://console.aws.amazon.com/directoryservice/?sc_channel=el&sc_campaign=devopswave&sc_content=microsoft-pki-smart-card-authentication-amazon-workspaces&sc_geo=mult&sc_country=mult&sc_outcome=acq), view the details page of your AD Connector, scroll down to **Smart card authentication**.
    * Under **CA certificates**, select **Actions**, select **Register Certificate**.
    * Select **Choose file**, choose the certificate exported from previous step.
    * For **OCSP responder URL**, enter your OCSP responder URL.  
![Image showing the "Register a certificate" dialog in AWS console where a sample exported root certificate was uploaded and a OCSP responder URL was added](./images/33-Register-a-certificate.png)

    * Select **Register certificate**.
    * Repeat the above steps again for each certificate in your certificate chain that you exported.
    * After all of the certificates have been registered, select **Enable** under **Smart Card authentication**, and select **Enable**, which will enable smart card authentication for the entire AD Connector.

## Section 8: Test pre-session smart card authentication on Windows WorkSpaces

Use the WorkSpaces client to test smart card authentication:

* Download the latest _WorkSpaces client_ and open the client.
* Enter your registration code for your directory when prompted
* Select **Insert your smart card**, and
* Select your user’s certificate when prompted.  
![Image showing the WorkSpaces Client with a Certificate Dialog prompt directing the user to select a certificate for authentication](./images/34-WorkSpaces-Client-with-Certificate-Dialog.png)

* Enter the smart card pin when prompted:  
![Image showing the WorkSpaces Client with a Certificate Dialog prompt directing the user to enter their authentication PIN](./images/35-WorkSpaces-Client-with-Certificate-Dialog-prompt.png)

* This completes the TLS mutual authentication with AD Connector login phase.
* Next, you will be presented with the Windows logon page.
* Select **Sign-in options**, select the smart card icon, and enter your smart card PIN:  
![Image showing the WorkSpaces Client at the Windows logon screen where the user enters their smart card PIN again](./images/36-WorkSpaces-Client-Windows-logon-screen.png)

This completes pre-session smart card authentication with Windows WorkSpaces.

## Section 9: Test in-session smart card authentication on Windows WorkSpaces

Within a WorkSpaces session, test in-session smart card authentication:

* Connect to the WorkSpace.
* RDP into an EC2 instance or computer using your smart card and enter your PIN when prompted.  
![Image showing a Microsoft Remote Desktop Connection window connecting to a sample computer "ENTCA1"](./images/37-Microsoft-Remote-Desktop-Connection.png)  
![Image: Image showing a Windows Security prompt requesting a smart card PIN to be entered](./images/38-Windows-Security-prompt-requesting-smart-card-PIN.png)

This completes in-session smart card authentication with Windows WorkSpaces.

## Section 10: Setup smart card authentication on Linux WorkSpaces (GovCloud only)

Smart card authentication is supported on Amazon Linux 2 WorkSpaces using the WSP protocol in the us-gov-west-1 region. To set this up, you will need to create a custom image that contains the certificates in your certificate chain.

1. Create a temporary Linux WSP WorkSpace:
    * _Launch a WSP WorkSpace_ for your test user and wait for it to become available.
2. Connect to the WorkSpace using the client (requires smart card authentication being disabled on your AD Connector for this part).
3. Configure the WorkSpace to allow users in a specific AD group of your choosing to SSH into the WorkSpaces:
    * Follow the steps to _Grant SSH access to Amazon Linux **WorkSpaces** administrators_.
    * Adjust the security group attached to your WorkSpaces to _allow SSH from desired IPs._
4. From a Windows computer in your AD environment, export ALL of the certificates in your certificate chain in DER format (not including the user certificate). You can do this using **certmgr.msc** from any AD-joined Windows computer in your environment.
5. Use PowerShell from one of your Windows computers in your AD environment (e.g. MGMT instance) to copy the certificates onto the WorkSpace using SCP:  

   ```powershell
   scp C:\Users\**Administrator**\Desktop\**root.cer example\testuser**@**workspace-ip-address**:~/
   scp C:\Users\**Administrator**\Desktop\**int.cer example\testuser**@**workspace-ip-address**:~/
   ```

6. Once the certificates are copied to the WorkSpace, convert each of your certificates into PEM format using Terminal:  

   ```powershell
   openssl x509 -inform der -in ~**/root.cer** -out **/tmp/root.pem**
   openssl x509 -inform der -in ~**/int.cer** -out **/tmp/int.pem**
   ```

7. Prepare the WorkSpace for smart card authentication by running the following commands to enable smart card authentication by referring each certificate in the certificate chain:  

   ```powershell
   sudo su
   cd /usr/lib/skylight/
   ./enable_smartcard --ca-cert **/tmp/root.pem /tmp/int.pem**
   ```

8. Disconnect from the WorkSpace and _create a custom image_ from the WorkSpace.
9. Create a bundle from the image once the image is finished creating.
10. Launch a WorkSpace for your test smart card user from your custom bundle.

## Section 11: Test smart card authentication on Linux WorkSpaces (GovCloud only)

Use the WorkSpaces client to test smart card authentication:

* Open the WorkSpaces client.
* Enter your registration code for your directory, if prompted
* Select **Insert your smart card**, and select your user’s certificate when prompted.  
![Image showing the WorkSpaces Client with a Certificate Dialog prompt directing the user to select a certificate for authentication](./images/34-WorkSpaces-Client-with-Certificate-Dialog.png)

* Enter the smart card pin when prompted:  
![Image showing the WorkSpaces Client with a Certificate Dialog prompt directing the user to enter their authentication PIN](./images/35-WorkSpaces-Client-with-Certificate-Dialog-prompt.png)

* This completes the TLS mutual authentication with AD Connector login phase.
* Enter your PIN at the logon page.  
![Image showing the WorkSpaces Client at the Linux logon page requesting the user to enter their smart card PIN again](./images/39-WorkSpaces-Client-at-the-Linux-logon-page.png)

* This completes pre-session smart card authentication with Linux WorkSpaces.

## Troubleshooting

1. Certificate validation failed error in the WorkSpaces client:  
![Image showing the WorkSpaces client returning a "Unable to sign in" "Certification validation failed" error](./images/43-WorkSpaces-client-returning-Unable-to-sign-in.png)
    Certificate validation failed indicates a failure before or during the mutual TLS authentication phase that occurs with the AD Connector. This can be caused due to various reasons including the following:
    * The AD Connector’s service account does not have the correct Kerberos Constrained Delegation Settings. Ensure the service account is delegated access to the LDAP service on each DC that it can authenticate with, refer to _this_.
    * The Kerberos supported encryption types for your service account and domain controllers do not match. If you are using self-managed AD, collect the packet captures on each DC when reproducing the issue and analyze the Kerberos and LDAP traffic from the AD Connector IPs for any errors.
    * OCSP validation is failing. Refer to the previous Section 5 Step 4 to test OCSP validation.
    * The AD Connector registered certificates for smart card authentication are not correct.
    * The local computer using the WorkSpaces client does not have the certificates in the certificate chain installed in the local store.
    * The smart card is failing to redirect the certificate into the user’s personal store.
    * A proxy or local networking configuration is interfering with the authentication process.

2. WorkSpaces client returns an error - Unknown Error Occurred:  
![Image showing the WorkSpaces client returning a "Unknown Error Occurred" error](./images/40-WorkSpaces-client-returning-Unknown-Error-Occurred.png)
This indicates that the mutual TLS authentication with AD Connector was successful, but an issue prevented the client from starting smart card authentication. This can be caused by the following:
    * The WSP GPO template to enable smart card redirection is not configured or is set to deny.
    * The user certificate fails to be redirected into the WorkSpace.

3. At the Windows WorkSpace logon screen, various errors can be reported during smart card authentication:  
![Image showing the Windows logon page returning a "Signing in with a smart card is not supported for your account error](./images/41-Windows-logon-page-returning-Signing-smart-card-is-not-supported.png)
    The above error indicates a Windows OS-level smart card authentication failure. This and other related errors at this logon screen can be caused due to the following reasons:
    * The domain controller authenticating the user does not have a certificate in the personal store. Review the Event Viewer logs on the WorkSpace.
    * The user’s smart card certificate is not trusted by the WorkSpace. Connect to the WorkSpace using RDP and confirm what certificate is being redirected into the user’s personal store and ensure it is trusted.
    * The user’s certificate is not configured correctly for Windows smart card authentication.
4. At the Linux WorkSpace logon screen, various errors can be reported during smart card authentication:  
![Image showing the Linux logon page returning a Sorry, that did not work Please try again. error when entering a smart card PIN](./images/42-Linux-logon-page-returning-Sorry-that-did-not-work.png)
    The above error indicates a Linux OS-level smart card authentication failure. This and other related errors at this logon screen can be caused due to the following reasons:
    * The custom image used to create the WorkSpace does not have the correct certificates in the certificate chain added in the image.
    * A separate OS-level authentication issue. SSH into the WorkSpace and review the logs in /var/log for any errors around the timestamp.

## Cleaning up

1. Disable smart card authentication on the AD Connector:
    * Open _Directory Services console_, view the details page of your AD Connector, scroll down to Smart card authentication.
    * Select **Disable** under Smart Card authentication, which will disable smart card authentication for the entire AD Connector.
2. Delete any existing WorkSpaces:
    * Open _Amazon **WorkSpaces** console_, select any existing WorkSpaces and select **Delete**.
    * Wait for the WorkSpaces to terminate.
3. Delete the custom bundle and image for your Linux WorkSpaces:
    * Open _Amazon **WorkSpaces** console_, select **Bundles**, select your bundle and select **Delete**.
    * Select **Images**, select your image, and select **Delete**.
4. Deregister the AD Connector from WorkSpaces:
    * Open _Amazon **WorkSpaces** console_ and select **Directories**.
    * Select the directory, choose **Actions**, and choose **Deregister**.
5. Delete the OCSP EC2 instance:
    * Open _EC2 console_ and select **Instances**.
    * Locate the OCSP instance, select it, select **Instance state**, select **Terminate instance**.
6. If you deployed the Microsoft PKI Quick Start Template:
    * Open _CloudFormation console_ and select the created stack.
    * Select **Delete**.
7. If you created an S3 bucket to store the CRLs:
    * Open _S3 console_ and select the created bucket.
    * Select Delete.
8. Delete the secret in Secrets Manager:
    * Open _Secrets Manager console_ and select **Secrets** on the left-side.
    * Choose the secret your created, select **Actions**, and select **Delete** secret.
9. Remove the Kerberos Constrained Delegation setting from your AD Connector service account.
10. Clean up any created DNS records, AD users, groups, and group policies your environment.

## Conclusion

In this post, you learned how to setup and configure a new or your existing Microsoft PKI environment for use with smart card authentication for Amazon WorkSpaces. Now, your users are able to authenticate into their WorkSpaces using their smart cards.
