### Abstract: This PoSH Script Notifies Mailbox Enabled Users For Which The Account And/Or Password Will Expire Within A Specific Number Of Days
###
### Written by: Jorge de Almeida Pinto [MVP-EMS]
### BLOG: http://jorgequestforknowledge.wordpress.com/
### E-Mail Address For Feedback/Questions: scripts.gallery@iamtec.eu
###
### Paste The Following Quick Link Between The Double Quotes In Browser To Send Mail:
### --> "mailto:Jorge's Script Gallery <scripts.gallery@iamtec.eu>?subject=[Script Gallery Feedback:] 'REPLACE-THIS-PART-WITH-SOMETHING-MEANINGFULL'"
###
### For Questions/Feedback:
### --> Please Describe Your Scenario As Best As Possible With As Much Detail As Possible.
### --> If Applicable Describe What Does and Does Not Work.
### --> If Applicable Describe What Should Be/Work Different And Explain Why/How.
### --> Please Add Screendumps.
###

<#
.SYNOPSIS
	This PoSH Script Notifies Mailbox Enabled Users For Which The Account And/Or Password Will Expire Within A Specific Number Of Days

.VERSION
	v0.9, 2020-04-14 (UPDATE THE VERSION VARIABLE BELOW)
	
.AUTHOR
	Initial Script/Thoughts.......: Jorge de Almeida Pinto [MVP Enterprise Mobility And Security, EMS]
	Script Re-Written/Enhanced....: N.A.
	Blog..........................: Blog: http://jorgequestforknowledge.wordpress.com/
	For Feedback/Questions........: scripts.gallery@iamtec.eu ("mailto:Jorge's Script Gallery <scripts.gallery@iamtec.eu>?subject=[Script Gallery Feedback:] 'REPLACE-THIS-PART-WITH-SOMETHING-MEANINGFULL'")

.DESCRIPTION
	This PoSH script notifies mailbox enabled users for which the account and/or password will expire within a specific number of days.
	The configuration of the script is done through an XML file. The tool uses an XML called "AD-Exp-Notify.xml". It is pre-filled with
	examples from my test/demo environment. Make sure to change as needed to accommodate your own environment and requirements!
	For detailed information about all configurable options see the sample XML file or browse to: 

.TODO
	- N.A.

.KNOWN ISSUES/BUGS
	- N.A.

.RELEASE NOTES
	v0.9, 2020-04-14, Jorge de Almeida Pinto [MVP-EMS]:
		- Added support for account expiry notification in addition to password expiry notification
		- In xml file changed main xml node name from ADPwdExpNotifyConfig to ADExpNotifyConfig
		- In the xml file change fullPathToLogFile to logFileFolderPath
		- In the xml file change fullPathToCSVFile to csvFileFolderPath
		- Added features node section to xml for difference in enabled/disabled features
		- Added featureName property to htmlBodyFile nodes in the XML
		- Changed the fullPath property to htmlBodyFullPath in the htmlBodyFile nodes in the XML
		- Added the attachedPictureFullPath property to the htmlBodyFile nodes in the XML
		- Added accountExpiryNotificationEnabled and pwdExpiryNotificationEnabled property to searchBase nodes
		- Added searchScope property (OneLevel Or Subtree) to searchBase nodes for more granualarity
		- Added support for URL to request extend the accounts in the XML
		- Added separate section per feature in the section daysBeforeWarn in the XML
		- Changed the property name 'min' to 'MinOrEqual' in the section daysBeforeWarn in the XML
		- Added support for Windows Server 2019 AD
		- Added mail function with additional logic
		- Added write to event log function
		- Updated the Logging function
		- Dropped support for custom config for logToScreen. By default will log to screen
		- Dropped support for custom config for logToFile. By default will log to file
		- Implement UAC check to make sure it does not break execution of the script
		- All script issues are mailed to e-mail address specified in toSMTPAddressSupport and not toSMTPAddressInTestMode
		- Bug fix: make sure that values exist in GPO and PSO
		- Bug fix: make sure to Null values before reuse
		- Checked script with Visual Studio Code and fixed all "problems" identified by Visual Studio Code
		- Code improvements/optimization throughout the code
		- Added more comments
		- added html body example for account expiry in US and NL language
		- Updated the output with different colors
		- Updates NOTES section

	v0.8, 2017-05-25, Jorge de Almeida Pinto [MVP-EMS]:
		- Added support for Windows Server 2016 AD
		- Added support for different URLs for Password Change, for Password Reset and for Registering for Self Service Password Reset
		- Added a check for the "Password Settings Container" container
		- Added more checks in the script
		- Added a check for so called DENY groups due to UAC
		- Added information regarding requirements to use the script and guidelines to test/implement the script

	v0.7, 2016-05-08, Jorge de Almeida Pinto [MVP-EMS]:
		- Resolved a bug with regards to array definition of the password policies in a domain ($pwdPolicyInDomain),
		- Resolved a bug with regards to testing the existence of the language files

	v0.6, 2015-10-13, Jorge de Almeida Pinto [MVP-EMS]:
		- Resolved a bug with regards to paging when searching

	v0.5, 2015-09-22, Jorge de Almeida Pinto [MVP-EMS]:
		- Bug fixes regarding specifying the script version and date after the parameter section

	v0.4, 2015-04-29, Jorge de Almeida Pinto [MVP-EMS]:
		- Bug fix regarding the default domain GPO getting no name when no PSOs are used or inheriting the name of the last processed PSO
		- Bug fix regarding the displayName of the development user not being processed correctly
		- More enhanced error detection when discovering a DC for non-existing AD domain
		- Better explanation and information about the parameters and the script itself

	v0.3, 2015-03-27, Jorge de Almeida Pinto [MVP-EMS]:
		- Supporting date/time format in XML and incorrect variable being used to get the correct password policy settings

	v0.2, 2015-03-26, Jorge de Almeida Pinto [MVP-EMS]:
		- Bug fixes regarding some attributes not having values

	v0.1, 2015-03-21, Jorge de Almeida Pinto [MVP-EMS]:
		- Initial version of the script


.PARAMETER force
	Runs the script in whatever mode is configured in the XML file (e.g. "DEV", "TEST" or "PROD" mode)

.PARAMETER xmlconfigfilepath
	Allows to use a custom location and custom XML file instead of the default XML file in the default location (same folder as the script)

.EXAMPLE
	Executing the script to run in "TEST (NO MAILINGS)" mode while using the default location of the XML configuration file (same folder as script)
	
	.\AD-Exp-Notify.ps1

.EXAMPLE 
	Executing the script to run in "DEV", "TEST" or "PROD" mode (whatever is configured in the XML configuration file) while using the default
	location of the XML configuration file (same folder as script)
	
	.\AD-Exp-Notify.ps1 -force
	
.EXAMPLE 
	Executing the script to run in "TEST (NO MAILINGS)" mode while using a custom location of the XML configuration file
	
	.\AD-Exp-Notify.ps1 -xmlconfigfilepath D:\TEMP\AD-Pwd-Exp-Notify.xml

.EXAMPLE
	Executing the script to run in "DEV", "TEST" or "PROD" mode (whatever is configured in the XML configuration file) while using custom location
	of the XML configuration file
	
	.\AD-Exp-Notify.ps1 -xmlconfigfilepath D:\TEMP\AD-Pwd-Exp-Notify.xml -force

.NOTES
	-->> DISCLAIMER <<--
	* I wrote this script, therefore I own it. Anyone asking money for it, should NOT be doing that and is basically ripping you off!
	* The script is freeware, you are free to use it and distribute it, but always refer to this website 
		(https://jorgequestforknowledge.wordpress.com/) as the location where you got it.
	* This script is furnished "AS IS". No warranty is expressed or implied!
	* I have NOT tested it in every scenario nor have I tested it against every Windows and/or AD version
	* ALWAYS TEST FIRST in lab environment to see if it meets your needs!
	* Use this script at your own risk! YOU ARE RESPONSIBLE FOR ANY OUTCOME BY USING THIS SCRIPT!
	* I do not warrant this script to be fit for any purpose, use or environment!
	* I have tried to check everything that needed to be checked, but I do not guarantee the script does not have bugs!
	* I do not guarantee the script will not damage or destroy your system(s), environment or whatever!
	* I do not accept liability in any way if you screw up, use the script wrong or in any other way where damage is caused to your
		environment/systems!
	* If you do not accept these terms DO NOT use the script in any way and delete it immediately!

	More information about this script can be found through:
	* PUBLIC: https://github.com/zjorz/Public-Scripts-AD/tree/master/AD-Expiry-Notification
	* PRIVATE: https://github.com/zjorz/Scripts-AD/tree/master/AD-Expiry-Notification
#>

Param(
	[Parameter(Mandatory=$false)]
	[string]$xmlconfigfilepath,
	[Parameter(Mandatory=$false)]
	[switch]$force
)

### FUNCTION: Logging Data To The Log File
Function Logging($dataToLog, $lineType) {
	$datetimeLogLine = "[" + $(Get-Date -format $formatDateTime) + "] : "
	Out-File -filepath "$logFilePath" -append -inputObject "$datetimeLogLine$dataToLog"
	If ($null -eq $lineType) {
		Write-Host "$datetimeLogLine$dataToLog" -ForeGroundColor Yellow
	}
	If ($lineType -eq "SUCCESS") {
		Write-Host "$datetimeLogLine$dataToLog" -ForeGroundColor Green
	}
	If ($lineType -eq "ERROR") {
		Write-Host "$datetimeLogLine$dataToLog" -ForeGroundColor Red
	}
	If ($lineType -eq "WARNING") {
		Write-Host "$datetimeLogLine$dataToLog" -ForeGroundColor Red
	}
	If ($lineType -eq "MAINHEADER") {
		Write-Host "$datetimeLogLine$dataToLog" -ForeGroundColor Magenta
	}
	If ($lineType -eq "HEADER") {
		Write-Host "$datetimeLogLine$dataToLog" -ForeGroundColor DarkCyan
	}
	If ($lineType -eq "REMARK") {
		Write-Host "$datetimeLogLine$dataToLog" -ForeGroundColor Cyan
	}
	If ($lineType -eq "REMARK-IMPORTANT") {
		Write-Host "$datetimeLogLine$dataToLog" -ForeGroundColor Green
	}
	If ($lineType -eq "REMARK-MORE-IMPORTANT") {
		Write-Host "$datetimeLogLine$dataToLog" -ForeGroundColor Yellow
	}
	If ($lineType -eq "REMARK-MOST-IMPORTANT") {
		Write-Host "$datetimeLogLine$dataToLog" -ForeGroundColor Red
	}
	If ($lineType -eq "ACTION") {
		Write-Host "$datetimeLogLine$dataToLog" -ForeGroundColor White
	}
	If ($lineType -eq "ACTION-NO-NEW-LINE") {
		Write-Host "$datetimeLogLine$dataToLog" -NoNewline -ForeGroundColor White
	}
}

### FUNCTION: Test The Port Connection
Function portConnectionCheck($fqdnServer, $port, $timeOut) {
	# Test To See If The HostName Is Resolvable At All
	Try {
		[System.Net.Dns]::gethostentry($fqdnServer) | Out-Null
	} Catch {
		Return "ERROR"
	}
	
	$tcpPortSocket = $null
	$portConnect = $null
	$tcpPortWait = $null
	$tcpPortSocket = New-Object System.Net.Sockets.TcpClient
	$portConnect = $tcpPortSocket.BeginConnect($fqdnServer, $port, $null, $null)
	$tcpPortWait = $portConnect.AsyncWaitHandle.WaitOne($timeOut, $false)
	If(!$tcpPortWait) {
		$tcpPortSocket.Close()
		Return "ERROR"
	} Else {
		#$error.Clear()
		$ErrorActionPreference = "SilentlyContinue"
		$tcpPortSocket.EndConnect($portConnect) | Out-Null
		If (!$?) {
			Return "ERROR"
		} Else {
			Return "SUCCESS"
		}
		$tcpPortSocket.Close()
		$ErrorActionPreference = "Continue"
	}
}

### FUNCTION: Write Event Log Of Specified Server
Function writeToEventLog($server, $eventLog, $eventSource, $eventID, $eventMessage, $eventType) {
	If (!([System.Diagnostics.EventLog]::SourceExists($eventSource, $server))) {
		New-EventLog -ComputerName $server -logname $eventLog -Source $eventSource
	}
	Write-EventLog -ComputerName $server -LogName $eventLog -Source $eventSource -EventID $eventID -Message $eventMessage -EntryType $eventType
}

### FUNCTION: Send E-mail With Information
Function sendMailMessage($mailServer, $mailFromSender, $mailToRecipient, $mailCcRecipient, $mailPriority, $mailSubject, $mailBody, $mailAttachments) {
	If ($mailCcRecipient) {
		# Mail WITH CC Recipient
		If ($mailAttachments) {
			# Mail WITH Attachment
			Send-MailMessage -SmtpServer $mailServer -From $mailFromSender -To $mailToRecipient -Cc $mailCcRecipient -Priority $mailPriority -Subject $mailSubject -Body $mailBody -BodyAsHtml -Attachments $mailAttachments
		} Else {
			# Mail WITHOUT Attachment
			Send-MailMessage -SmtpServer $mailServer -From $mailFromSender -To $mailToRecipient -Cc $mailCcRecipient -Priority $mailPriority -Subject $mailSubject -Body $mailBody -BodyAsHtml
		}
	} Else {
		# Mail WITHOUT CC Recipient
		If ($mailAttachments) {
			# Mail WITH Attachment
			Send-MailMessage -SmtpServer $mailServer -From $mailFromSender -To $mailToRecipient -Priority $mailPriority -Subject $mailSubject -Body $mailBody -BodyAsHtml -Attachments $mailAttachments
		} Else {
			# Mail WITHOUT Attachment
			Send-MailMessage -SmtpServer $mailServer -From $mailFromSender -To $mailToRecipient -Priority $mailPriority -Subject $mailSubject -Body $mailBody -BodyAsHtml
		}
	}
}

### FUNCTION: Send An E-Mail Due To Some Issue Found By/Through Script
Function sendEmailDueToIssue($mailToRecipient, $mailSubject, $mailIssueLine) {
	$mailCcRecipient = $null
	$mailPriority = "High"
	$mailAttachments = @()
	$mailAttachments += $logFilePath
	$mailBody = @"
<!DOCTYPE html>
<html>
<head>
<title>supportNotification_About-Some-Issue-Found</title>
<style type="text/css">
</style>
</head>
<body>
<B><P align="center" style="font-size: 24pt; font-family: Arial Narrow, sans-serif; color: red">!!! ATTENTION | FYI - ACTION REQUIRED !!!</P></B>
<hr size=2 width="95%" align=center>
<BR>
<P style="font-size: 12pt; font-family: Arial Narrow, sans-serif;">Hello,</P>
<BR>
<P style="font-size: 12pt; font-family: Arial Narrow, sans-serif;">$mailIssueLine</P>
<P style="font-size: 12pt; font-family: Arial Narrow, sans-serif;">Please investigate this as soon as possible. The log file is attached.</P>
<BR>
<P style="font-size: 12pt; font-family: Arial Narrow, sans-serif;">Best regards,</P>
<P style="font-size: 12pt; font-family: Arial Narrow, sans-serif;">Reported By: '$fqdnLocalComputer'</P>
</body>
</html>
"@

	### Send A Notification E-Mail About Some Issue That Was Found
	sendMailMessage $smtpServer $mailFromSender $mailToRecipient $mailCcRecipient $mailPriority $mailSubject $($mailBody | Out-String) $mailAttachments

	Logging "       --> Notifying '$mailToRecipient' about issue found..." "ERROR"
}

### FUNCTION: Send An E-Mail Due To Notifying The Recipient About Some Expiration
Function sendEmailDueToExpiration($user, $expirationType, $mailToRecipient) {
	# Only When It Concerns Notifications For Account Expiry
	If ($expirationType -eq "accountExpiryNotification") {
		# Retrieve The Subject Line Determined For The User
		$mailSubjectForUser = $null
		$mailSubjectForUser = $user."Mail Subject (Acc Exp Not)"
		
		# Retrieve The HTML Body File Determined For The User
		$htmlBodyFileForUser = $null
		$htmlBodyFileForUser = $user."HTML Body File (Acc Exp Not)"

		# Retrieve The Picture File Determined For The User
		$pictureFileForUser = $null
		$pictureFileForUser = $user."Picture File (Acc Exp Not)"
	}

	# Only When It Concerns Notifications For Password Expiry
	If ($expirationType -eq "pwdExpiryNotification") {
		# Get The Effective PWD Policy On The User
		$effectivePWDPolicyNameOnUser = $null
		$effectivePWDPolicyNameOnUser = $user."Effective PWD Policy"
		$effectivePWDPolicyOnUser = $null
		$effectivePWDPolicyOnUser = $pwdPolicyInDomain | Where-Object{$_.Name -eq $effectivePWDPolicyNameOnUser}

		# Get The Settings Of The Effective PWD Policy On The User
		$policyPWDMinLength = $null
		$policyPWDMinLength = $effectivePWDPolicyOnUser.MinPwdLength
		$policyPWDMinAge = $null
		$policyPWDMinAge = $effectivePWDPolicyOnUser.MinPwdAge
		$policyPWDMaxAge = $null
		$policyPWDMaxAge = $effectivePWDPolicyOnUser.MaxPwdAge
		$policyPWDHistory = $null
		$policyPWDHistory = $effectivePWDPolicyOnUser.PwdHistoryLength
		$policyPWDComplexity = $null
		$policyPWDComplexity = $effectivePWDPolicyOnUser.PwdComplexity
		
		# Retrieve The Subject Line Determined For The User
		$mailSubjectForUser = $null
		$mailSubjectForUser = $user."Mail Subject (Pwd Exp Not)"
		
		# Retrieve The HTML Body File Determined For The User
		$htmlBodyFileForUser = $null
		$htmlBodyFileForUser = $user."HTML Body File (Pwd Exp Not)"

		# Retrieve The Picture File Determined For The User
		$pictureFileForUser = $null
		$pictureFileForUser = $user."Picture File (Pwd Exp Not)"
	}

	# Replace Any Variables In The Subject Line With The Actual Values
	$mailSubject = $null
	$mailSubject = $mailSubjectForUser -replace "FQDN_DOMAIN",$user."FQDN AD Domain"
	$mailSubject = $mailSubject -replace "NBT_DOMAIN",$user."NBT AD Domain"
	$mailSubject = $mailSubject -replace "FIRST_NAME",$user."Given Name"
	$mailSubject = $mailSubject -replace "LAST_NAME",$user."Last Name"
	$mailSubject = $mailSubject -replace "DISPLAY_NAME",$user."Display Name"
	$mailSubject = $mailSubject -replace "EMAIL_ADDRESS",$user."E-Mail Address"
	$mailSubject = $mailSubject -replace "UPN",$user."UPN"
	$mailSubject = $mailSubject -replace "SAM_ACCOUNT_NAME",$user."Sam Account Name"
	$mailSubject = $mailSubject -replace "PRINCIPAL_ACCOUNT_NAME",$user."Principal Account Name"
	
	# Only When It Concerns Notifications For Account Expiry
	If ($expirationType -eq "accountExpiryNotification") {
		$mailSubject = $mailSubject -replace "ACCOUNT_EXPIRY_DATE",$user."Account Expiry Date"
		$mailSubject = $mailSubject -replace "ACCOUNT_EXPIRE_IN_NUM_DAYS",[math]::Round($user."Days Until Account Expiry")
		$mailSubject = $mailSubject -replace "ACCOUNT_EXTENSION_URL",$accountExtensionURL
	}

	# Only When It Concerns Notifications For Password Expiry
	If ($expirationType -eq "pwdExpiryNotification") {
		$mailSubject = $mailSubject -replace "PWD_LAST_SET",$user."PWD Last Set"
		$mailSubject = $mailSubject -replace "PWD_EXPIRY_DATE",$user."PWD Expire Date"
		$mailSubject = $mailSubject -replace "PWD_EXPIRE_IN_NUM_DAYS",[math]::Round($user."Days Until PWD Expiry")
		$mailSubject = $mailSubject -replace "PWD_MIN_LENGTH",$policyPWDMinLength
		$mailSubject = $mailSubject -replace "PWD_MIN_AGE",$policyPWDMinAge
		$mailSubject = $mailSubject -replace "PWD_MAX_AGE",$policyPWDMaxAge
		$mailSubject = $mailSubject -replace "PWD_HISTORY",$policyPWDHistory
		$mailSubject = $mailSubject -replace "PWD_COMPLEX",$policyPWDComplexity
		$mailSubject = $mailSubject -replace "PWD_CHANGE_URL",$pwdChangeURL
		$mailSubject = $mailSubject -replace "SSPR_REGISTRATION_URL",$ssprRegistrationURL
		$mailSubject = $mailSubject -replace "PWD_RESET_URL",$pwdResetURL
	}

	# Replace Any Variables In The BODY With The Actual Values
	$pictureFileName = $null
	$pictureFileName = Split-Path $pictureFileForUser -Leaf
	$mailBodyForUser = $null
	$mailBodyForUser = Get-Content $htmlBodyFileForUser
	$mailBody = $null
	$mailBody = $mailBodyForUser -replace "IMAGE_BASE_FILE_NAME",$pictureFileName
	$mailBody = $mailBody -replace "FQDN_DOMAIN",$user."FQDN AD Domain"
	$mailBody = $mailBody -replace "NBT_DOMAIN",$user."NBT AD Domain"
	$mailBody = $mailBody -replace "FIRST_NAME",$user."Given Name"
	$mailBody = $mailBody -replace "LAST_NAME",$user."Last Name"
	$mailBody = $mailBody -replace "DISPLAY_NAME",$user."Display Name"
	$mailBody = $mailBody -replace "EMAIL_ADDRESS",$user."E-Mail Address"
	$mailBody = $mailBody -replace "UPN",$user."UPN"
	$mailBody = $mailBody -replace "SAM_ACCOUNT_NAME",$user."Sam Account Name"
	$mailBody = $mailBody -replace "PRINCIPAL_ACCOUNT_NAME",$user."Principal Account Name"

	# Only When It Concerns Notifications For Account Expiry
	If ($expirationType -eq "accountExpiryNotification") {
		$mailBody = $mailBody -replace "ACCOUNT_EXPIRY_DATE",$user."Account Expiry Date"
		$mailBody = $mailBody -replace "ACCOUNT_EXPIRE_IN_NUM_DAYS",[math]::Round($user."Days Until Account Expiry")
		$mailBody = $mailBody -replace "ACCOUNT_EXTENSION_URL",$accountExtensionURL
	}

	# Only When It Concerns Notifications For Password Expiry
	If ($expirationType -eq "pwdExpiryNotification") {
		$mailBody = $mailBody -replace "PWD_LAST_SET",$user."PWD Last Set"
		$mailBody = $mailBody -replace "PWD_EXPIRY_DATE",$user."PWD Expire Date"
		$mailBody = $mailBody -replace "PWD_EXPIRE_IN_NUM_DAYS",[math]::Round($user."Days Until PWD Expiry")
		$mailBody = $mailBody -replace "PWD_MIN_LENGTH",$policyPWDMinLength
		$mailBody = $mailBody -replace "PWD_MIN_AGE",$policyPWDMinAge
		$mailBody = $mailBody -replace "PWD_MAX_AGE",$policyPWDMaxAge
		$mailBody = $mailBody -replace "PWD_HISTORY",$policyPWDHistory
		$mailBody = $mailBody -replace "PWD_COMPLEX",$policyPWDComplexity
		$mailBody = $mailBody -replace "PWD_CHANGE_URL",$pwdChangeURL
		$mailBody = $mailBody -replace "SSPR_REGISTRATION_URL",$ssprRegistrationURL
		$mailBody = $mailBody -replace "PWD_RESET_URL",$pwdResetURL
	}

	# Attach Files To The Mail
	$mailAttachments = @()
	$mailAttachments += $pictureFileForUser

	# Potential Addresses For CC
	$mailCcRecipient = $null

	### Send A Notification E-Mail About The Expiring Account/Password
	sendMailMessage $smtpServer $mailFromSender $mailToRecipient $mailCcRecipient $mailPriority $mailSubject $($mailBody | Out-String) $mailAttachments

	Logging "" "REMARK"
	Logging "  --> Notifying '$($user."Display Name")' about $expirationType by sending an e-mail to '$mailToRecipient'" "REMARK"
}

### FUNCTION: Cleaning Up Old Log Files
Function cleanUpLOGFiles($numLOGsToKeep) {
	# RegEx Pattern For the Log File
	$regExPatternLogFile = '^.*AD-Exp-Notify_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}.log$'
	
	# All Log Files Matching The Pattern
	$oldLogFiles = Get-ChildItem -Path $logFileFolderPath\*.log | Where-Object{$_.Name -match $regExPatternLogFile}
	
	# All Log Files Determined To Be Deleted Based Upon The Number Of Log Files To Keep
	$oldLogFilesToDelete = $oldLogFiles | Where-Object{$_.lastwritetime -lt (Get-Date $execStartDateTime).addDays(-$numLOGsToKeep) -and -not $_.psiscontainer}
	
	# Deleting All Log Files Determined To Be Deleted
	$oldLogFilesToDelete | ForEach-Object{Remove-Item $_.FullName -force}

	# Number Of Log Files Deleted
	Return ($oldLogFilesToDelete | Measure-Object).Count
}

### FUNCTION: Cleaning Up Old Csv Files
Function cleanUpCSVFiles($numCSVsToKeep) {
	# RegEx Pattern For the CSV File
	$regExPatternCsvFile = '^.*AD-Exp-Notify_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}.csv$'
	
	# All CSV Files Matching The Pattern
	$oldCsvFiles = Get-ChildItem -Path $csvFileFolderPath\*.csv | Where-Object{$_.Name -match $regExPatternCsvFile}
	
	# All CSV Files Determined To Be Deleted Based Upon The Number Of CSV Files To Keep
	$oldCsvFilesToDelete = $oldCsvFiles | Where-Object{$_.lastwritetime -lt (Get-Date $execStartDateTime).addDays(-$numCSVsToKeep) -and -not $_.psiscontainer}
	
	# Deleting All CSV Files Determined To Be Deleted
	$oldCsvFilesToDelete | ForEach-Object{Remove-Item $_.FullName -force}
	
	# Number Of CSV Files Deleted
	Return ($oldCsvFilesToDelete | Measure-Object).Count
}

### FUNCTION: Discover An RWDC From An AD Domain
Function discoverRWDC($fqdnADdomain) {
	# Create The Directory Context For The AD Domain
	$contextADDomain = $null
	$contextADDomain = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("Domain",$fqdnADdomain)
	
	# Find One Writable DC
	$dnsHostNameRWDC = $null
	$ErrorActionPreference = "SilentlyContinue"
	$dnsHostNameRWDC = ([System.DirectoryServices.ActiveDirectory.DomainController]::findone($contextADDomain)).Name
	$ErrorActionPreference = "Continue"

	# If Nothing Was Returned, Then Either The AD Domain Does Not Exist Or There Was An Issue Finding One RWDC, And In That Case Return An Error
	# Otherwise The FQDN Of The Determined RWDC
	If ($null -eq $dnsHostNameRWDC) {
		Return "DOMAIN_DOES_NOT_EXIST_OR_CANNOT_FIND_DC"
	} Else {
		Return $dnsHostNameRWDC
	}
}

### FUNCTION: Discover A GC From The AD Forest
Function discoverGC() {
	# Determine The Name Of The AD Forest
	$adForestFQDN = $null
	$adForestFQDN = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Name.ToString()

	# Create The Directory Context For The AD Forest
	$contextADForest = $null
	$contextADForest = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("Forest", $adForestFQDN)

	# Find One Global Catalog
	$dnsHostNameGC = $null
	$ErrorActionPreference = "SilentlyContinue"
	$dnsHostNameGC = ([System.DirectoryServices.ActiveDirectory.GlobalCatalog]::findone($contextADForest)).Name
	$ErrorActionPreference = "Continue"

	# If Nothing Was Returned, Then There Was An Issue Finding One GC, And In That Case Return An Error
	# Otherwise The FQDN Of The Determined GC
	If ($null -eq $dnsHostNameGC) {
		Return "CANNOT_FIND_GC"
	} Else {
		Return $dnsHostNameGC
	}
}

### FUNCTION: Check If An OU/Container Exists
Function checkDNExistence($dnsHostNameRWDC, $dn) {
	Try {            
		If([ADSI]::Exists("LDAP://$dnsHostNameRWDC/$dn")) {            
			Return "SUCCESS"
		} Else {            
			Return "ERROR"
		}
	} Catch {            
		Return "ERROR"
	}
}

### FUNCTION: Decode Functional Level
Function decodeFunctionalLevel($dfl) {
	Switch ($dfl) { 
		0 {"Windows Server 2000"}
		1 {"Windows Server 2003 Interim"} 
		2 {"Windows Server 2003"} 
		3 {"Windows Server 2008"} 
		4 {"Windows Server 2008 R2"} 
		5 {"Windows Server 2012"} 
		6 {"Windows Server 2012 R2"} 
		7 {"Windows Server 2016"} # Also Applies to Windows Server 2019
		#8 {"TBD"} 
		#9 {"TBD"}
		#10 {"TBD"}
		Default {"If You See This, Something Is Wrong!"}
    }
}

### Version Of Script
$version = "v0.9, 2020-04-14"

### Clear The Screen
Clear-Host

### Configure The Appropriate Screen And Buffer Size To Make Sure Everything Fits Nicely
$uiConfig = (Get-Host).UI.RawUI
$uiConfig.WindowTitle = "+++ AD ACCOUNT/PASSWORD EXPIRY NOTIFICATION +++"
$uiConfig.ForegroundColor = "Yellow"
$uiConfigBufferSize = $uiConfig.BufferSize
$uiConfigBufferSize.Width = 500
$uiConfigBufferSize.Height = 9999
$uiConfigScreenSizeMax = $uiConfig.MaxPhysicalWindowSize
$uiConfigScreenSizeMaxWidth = $uiConfigScreenSizeMax.Width
$uiConfigScreenSizeMaxHeight = $uiConfigScreenSizeMax.Height
$uiConfigScreenSize = $uiConfig.WindowSize
If ($uiConfigScreenSizeMaxWidth -lt 180) {
	$uiConfigScreenSize.Width = $uiConfigScreenSizeMaxWidth
} Else {
	$uiConfigScreenSize.Width = 180
}
If ($uiConfigScreenSizeMaxHeight -lt 75) {
	$uiConfigScreenSize.Height = $uiConfigScreenSizeMaxHeight - 5
} Else {
	$uiConfigScreenSize.Height = 75
}
$uiConfig.BufferSize = $uiConfigBufferSize
$uiConfig.WindowSize = $uiConfigScreenSize

### Script Configuration File
If ($xmlconfigfilepath -eq $null -or $xmlconfigfilepath -eq "") {
	$currentScriptFolderPath = Split-Path $MyInvocation.MyCommand.Definition
	[string]$scriptXMLConfigFilePath = Join-Path $currentScriptFolderPath "AD-Exp-Notify.xml"
} Else {
	[string]$scriptXMLConfigFilePath = $xmlconfigfilepath
}

### Start Time Of Script In UTC
$execStartDateTime = (Get-Date -format $formatDateTime)
$execStartDateTimeForFileSystem = (Get-Date $execStartDateTime -format "yyyy-MM-dd_HH.mm.ss")

### Local Computer Name, Domain And FQDN
$localComputerName = $(Get-WmiObject -Class Win32_ComputerSystem).Name
$fqdnDomainName = $(Get-WmiObject -Class Win32_ComputerSystem).Domain
$script:fqdnLocalComputer = $localComputerName + "." + $fqdnDomainName

### User Account And Context Information
$contextCurrentUserAccount = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentUserAccount = $contextCurrentUserAccount.Name
$currentUserAccountClaims = $contextCurrentUserAccount.Claims

### Script Context Information
$currentScriptPath = $MyInvocation.MyCommand.Definition
$currentScriptFileName = Split-Path $currentScriptPath -Leaf

### Read The XML Config File
If (!(Test-Path $scriptXMLConfigFilePath)) {
    Write-Host "The XML Config File '$scriptXMLConfigFilePath' CANNOT Be Found!..." -ForeGroundColor Red
    Write-Host "Aborting Script..." -ForeGroundColor Red
    EXIT
} Else {
    [XML]$script:configADExpNotify = Get-Content $scriptXMLConfigFilePath
    #Write-Host "The XML Config File '$scriptXMLConfigFilePath' Has Been Found!..." -ForeGroundColor Green
    #Write-Host "Continuing Script..." -ForeGroundColor Green
    #Write-Host ""
}

### Read The Properties From The XML Config File
$features = $configADExpNotify.ADExpNotifyConfig.features.feature
$executionMode = $configADExpNotify.ADExpNotifyConfig.executionMode
$script:mailFromSender = $configADExpNotify.ADExpNotifyConfig.mailFromSender
$script:toSMTPAddressInTestMode = $configADExpNotify.ADExpNotifyConfig.toSMTPAddressInTestMode
$script:toSMTPAddressSupport = $configADExpNotify.ADExpNotifyConfig.toSMTPAddressSupport
$script:smtpServer = $configADExpNotify.ADExpNotifyConfig.smtpServer
$script:mailPriority = $configADExpNotify.ADExpNotifyConfig.mailPriority
#$mailSubject = $configADExpNotify.ADExpNotifyConfig.mailSubject
$htmlBodyFiles = $configADExpNotify.ADExpNotifyConfig.htmlBodyFiles.htmlBodyFile
$script:pwdChangeURL = $configADExpNotify.ADExpNotifyConfig.pwdChangeURL
$script:ssprRegistrationURL = $configADExpNotify.ADExpNotifyConfig.ssprRegistrationURL
$script:pwdResetURL = $configADExpNotify.ADExpNotifyConfig.pwdResetURL
$script:accountExtensionURL = $configADExpNotify.ADExpNotifyConfig.accountExtensionURL
$logFileFolderPath = $configADExpNotify.ADExpNotifyConfig.logFileFolderPath
$script:logFilePath = Join-Path $logFileFolderPath "AD-Exp-Notify_$execStartDateTimeForFileSystem.log"
$numLOGsToKeep = $configADExpNotify.ADExpNotifyConfig.numLOGsToKeep
$exportToCSV = $configADExpNotify.ADExpNotifyConfig.exportToCSV
$csvFileFolderPath = $configADExpNotify.ADExpNotifyConfig.csvFileFolderPath
$csvFilePath = Join-Path $csvFileFolderPath "AD-Exp-Notify_$execStartDateTimeForFileSystem.csv"
$numCSVsToKeep = $configADExpNotify.ADExpNotifyConfig.numCSVsToKeep
$formatDateTime = $configADExpNotify.ADExpNotifyConfig.formatDateTime
$domains = $configADExpNotify.ADExpNotifyConfig.domains.domain
$daysBeforeWarn = $configADExpNotify.ADExpNotifyConfig.daysBeforeWarn.feature

### Presentation Of Script Header
Logging ""
Logging "                                          **********************************************************" "MAINHEADER"
Logging "                                          *                                                        *" "MAINHEADER"
Logging "                                          *     --> AD Account/Password Expiry Notification <--    *" "MAINHEADER"
Logging "                                          *                                                        *" "MAINHEADER"
Logging "                                          *      Written By: Jorge de Almeida Pinto [MVP-EMS]      *" "MAINHEADER"
Logging "                                          *                                                        *" "MAINHEADER"
Logging "                                          *            BLOG: Jorge's Quest For Knowledge           *" "MAINHEADER"
Logging "                                          *   (URL: http://jorgequestforknowledge.wordpress.com/)  *" "MAINHEADER"
Logging "                                          *                                                        *" "MAINHEADER"
Logging "                                          *                    $version                    *" "MAINHEADER"
Logging "                                          *                                                        *" "MAINHEADER"
Logging "                                          **********************************************************" "MAINHEADER"
Logging "" "REMARK"
Logging "Starting Date And Time...........: $execStartDateTime" "REMARK"
Logging "" "REMARK"

### Checking The SMTP Server Is Reachable/Available, Write To The Event Log (Application) If Not Available And Abort The Script
$connectionResult = $null
$connectionResult = portConnectionCheck $smtpServer 25 500
If ($connectionResult.ToUpper() -eq "ERROR") {
	Logging "SMTP Server......................: $smtpServer (Status: $connectionResult)" "REMARK"
	Logging "" "REMARK"
	$eventLog = "Application"
	$eventSource = "AD Expiry Notification"
	$eventID = "9999"
	$eventMessage = "The Mail Server '$smtpServer' Is Not Reachable/Available!`r`nPlease Check Connectivity Is Possible From '$fqdnLocalComputer' Over Port 25`r`nPlease Check It Is Up And Running..."
	$eventType = "Warning"
	$server = $fqdnLocalComputer
	writeToEventLog $server $eventLog $eventSource $eventID $eventMessage $eventType

	EXIT
}

### Checking If UAC Is Impacting The User Running The Script Or Not.
# If It Is, Send An E-Mail About It And Abort The Script
# If It Is Not, Continue The Script
$denySIDs = $currentUserAccountClaims | Where-Object{$_.Type -eq 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/denyonlysid'}
If ($denySIDs) {
	Logging "" "WARNING"
	Logging "UAC Impacting Execution Of Script: YES" "WARNING"
	Logging "" "WARNING"
	$mailSubject = "ERROR: AD Expiry Notification Script: UAC Impact On User Account '$currentUserAccount' For '$currentScriptFileName'!"
	$mailIssueLine = "UAC may have an impact on the user account '$currentUserAccount' when running the script '$currentScriptPath' on '$fqdnLocalComputer'"

	sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine

	Logging "Aborting Script!..." "WARNING"
	Logging "" "WARNING"

	EXIT
} Else {
	Logging "" "SUCCESS"
	Logging "UAC Impacting Execution Of Script: NO" "SUCCESS"
	Logging "" "SUCCESS"
}

### Determining Globally Enabled Features
$accountExpiryNotificationEnabled = ($features | Where-Object{$_.name -eq "accountExpiryNotification"}).enabled
$pwdExpiryNotificationEnabled = ($features | Where-Object{$_.name -eq "pwdExpiryNotification"}).enabled

### Logging All Configured Settings
Logging "------------------------------------------------------------------------------------------------------------------------------------" "HEADER"
Logging "" "ACTION"
Logging "Operational Details..." "ACTION"
Logging "" "REMARK"
Logging "XML Config File Path.............: $scriptXMLConfigFilePath" "REMARK"
Logging "" "REMARK"
If (!$force) {
	$executionMode = "TEST (NO MAILINGS)"
}
Logging "Execution Mode...................: $executionMode" "REMARK"
Logging "" "REMARK"
Logging "Log File Full Path...............: $logFilePath" "REMARK"
Logging "" "REMARK"
Logging "Log Files Folder.................: $logFileFolderPath" "REMARK"
Logging "" "REMARK"
Logging "Number Of Logs To Keep...........: $numLOGsToKeep" "REMARK"
Logging "" "REMARK"
Logging "Export List Of User To CSV.......: $exportToCSV" "REMARK"
Logging "" "REMARK"
Logging "CSV File Full Path...............: $csvFilePath" "REMARK"
Logging "" "REMARK"
Logging "CSV Files Folder.................: $csvFileFolderPath" "REMARK"
Logging "" "REMARK"
Logging "Number Of Days Of CSVs To Keep...: $numCSVsToKeep" "REMARK"
Logging "" "REMARK"
Logging "SMTP Server......................: $smtpServer (Status: $connectionResult)" "REMARK"
Logging "" "REMARK"
Logging "Sender Address...................: $mailFromSender" "REMARK"
Logging "" "REMARK"
If ($executionMode.ToUpper() -eq "TEST (NO MAILINGS)") {
	Logging "Recipient Address................: None" "REMARK"
}
If ($executionMode.ToUpper() -eq "DEV" -Or $executionMode.ToUpper() -eq "TEST") {
	Logging "Recipient Address................: $toSMTPAddressInTestMode" "REMARK"
}
If ($executionMode.ToUpper() -eq "PROD") {
	Logging "Recipient Address................: Individual Users" "REMARK"
}
Logging "" "REMARK"
Logging "Message Priority.................: $mailPriority" "REMARK"
Logging "" "REMARK"
Logging "Account Exp. Notification Enabled: $accountExpiryNotificationEnabled" "REMARK"
Logging "" "REMARK"
Logging "Pwd Exp. Notification Enabled....: $pwdExpiryNotificationEnabled" "REMARK"
Logging "" "REMARK"
$htmlBodyFiles | Sort-Object -Property featureName,language | ForEach-Object{
	# Retrieve The Details Of The HTML Body File
	$featureName = $_.featureName
	$language = $_.language
	$mailSubject = $_.mailSubject
	$htmlBodyFileFullPath = $_.htmlBodyFullPath
	$attachedPictureFullPath = $_.attachedPictureFullPath

	# Only Check For The Existence Of The HTML Body Of The Feature That Is Enabled Globally. Report Through Mail If Any HTML Body File Does Not Exist And Abort The Script In That Case
	If (($accountExpiryNotificationEnabled -eq $true -And $featureName -eq "accountExpiryNotification") -Or ($pwdExpiryNotificationEnabled -eq $true -And $featureName -eq "pwdExpiryNotification")) {
		If (!(Test-Path $htmlBodyFileFullPath) -Or !(Test-Path $attachedPictureFullPath)) {
			Logging "" "ERROR"
			If (!(Test-Path $htmlBodyFileFullPath)) {
				Logging "The Language File '$htmlBodyFileFullPath' Does Not Exist!..." "ERROR"
				Logging "" "ERROR"
			}
			If (!(Test-Path $attachedPictureFullPath)) {
				Logging "The Picture File '$attachedPictureFullPath' Does Not Exist!..." "ERROR"
				Logging "" "ERROR"
			}
			If (!(Test-Path $htmlBodyFileFullPath)) {
				$mailSubject = "ERROR: AD Expiry Notification Script: Language File '$htmlBodyFileFullPath' Does Not Exist!"
				$mailIssueLine = "The HTML Body File '$htmlBodyFileFullPath' is missing on the server '$fqdnLocalComputer'"
			
				sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine
			}
			If (!(Test-Path $attachedPictureFullPath)) {
				$mailSubject = "ERROR: AD Expiry Notification Script: Picture File '$attachedPictureFullPath' Does Not Exist!"
				$mailIssueLine = "The Picture File '$attachedPictureFullPath' is missing on the server '$fqdnLocalComputer'"
			
				sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine
			}

			Logging "Aborting Script!..." "ERROR"
			Logging "" "ERROR"

			EXIT
		} Else {
			Logging "HTML Body File...................: $htmlBodyFileFullPath" "REMARK"
			Logging "Picture File.....................: $attachedPictureFullPath" "REMARK"
			Logging "                                    > Feature: $featureName" "REMARK"
			Logging "                                    > Language: $language" "REMARK"
			Logging "                                    > Mail Subject: $mailSubject" "REMARK"
			Logging "" "REMARK"
		}
	}
}
Logging "Password Change URL..............: $pwdChangeURL" "REMARK"
Logging "" "REMARK"
Logging "SSPR Registration URL............: $ssprRegistrationURL" "REMARK"
Logging "" "REMARK"
Logging "Self Service Password Reset URL..: $pwdResetURL" "REMARK"
Logging "" "REMARK"
Logging "Account Extension Request URL....: $accountExtensionURL" "REMARK"
Logging "" "REMARK"
Logging "------------------------------------------------------------------------------------------------------------------------------------" "HEADER"
Logging "" "ACTION"
Logging "Cleaning Up Old Log Files And Old CSV Files..." "ACTION"
### Cleaning Up Old Log Files
Logging "" "REMARK"
Logging "Cleaning Up Old Log Files. Keeping Log Files From Last $numLOGsToKeep Days..." "REMARK"
$oldLogFilesToDeleteCount = cleanUpLOGFiles $numLOGsToKeep
Logging "  --> Number Of Old Log Files Deleted...: $oldLogFilesToDeleteCount" "REMARK"

### Cleaning Up Old Csv Files
Logging "" "REMARK"
Logging "Cleaning Up Old Csv Files. Keeping Csv Files From Last $numCSVsToKeep Days..." "REMARK"
$oldCsvFilesToDeleteCount = cleanUpCSVFiles $numCSVsToKeep
Logging "  --> Number Of Csv Log Files Deleted...: $oldCsvFilesToDeleteCount" "REMARK"
Logging "" "REMARK"
Logging "------------------------------------------------------------------------------------------------------------------------------------" "HEADER"

### It Is Only Required To Execute The Script If Any Of Its Features Are Enabled Globally
If ($accountExpiryNotificationEnabled -eq $true -Or $pwdExpiryNotificationEnabled -eq $true) {
	# Creating An Empty Array For All Queried Users, Meaning All The Users In The Defined Search Bases (Not Necessarily The Same List Of Users That Will Be Notified!) 
	$listOfQueriedUsers = @()

	# Processing Each Configured AD Domain In The XML Config File
	Logging "" "ACTION"
	Logging "Processing Configured AD Domains..." "ACTION"

	# Go Through Every Configured AD Domain In The XML Config File
	If ($domains) {
		$domains | ForEach-Object{
			# The FQDN Of The AD Domain Being Processed
			$fqdnADdomain = $null
			$fqdnADdomain = $_.FQDN
			Logging "" "HEADER"
			Logging "" "HEADER"
			Logging "** AD Domain: '$fqdnADdomain' **" "HEADER"
			
			# The FQDN Of The DC Listed In The XML Config File, Either Specifically Or Discovered Dynamically
			$fqdnDC = $null
			$fqdnDC = $_.DC
			
			# If DISCOVER Was Specified Instead Of A Specific (Static) DC, Then Discover The Nearest RWDC And Use That One
			$connectionResult = $null
			If ($fqdnDC.ToUpper() -eq "DISCOVER") {
				# Discover The RWDC For The AD Domain
				$fqdnDC = $null
				$fqdnDC = discoverRWDC $fqdnADdomain

				# Check The Outcome Of The Discovery To Determine If The RWDC Is Available Or Not
				If ($fqdnDC -eq "DOMAIN_DOES_NOT_EXIST_OR_CANNOT_FIND_DC") {
					$connectionResult = "ERROR"
					Logging "" "ERROR"
					Logging "  --> FQDN DC: $fqdnDC (Discovered) (Status: $connectionResult)" "ERROR"
				} Else {
					$connectionResult = $null
					$connectionResult = portConnectionCheck $fqdnDC 389 500
					If ($connectionResult -eq "SUCCESS") {
						Logging "" "SUCCESS"
						Logging "  --> FQDN DC: $fqdnDC (Discovered) (Status: $connectionResult)" "SUCCESS"
					} Else {
						Logging "" "ERROR"
						Logging "  --> FQDN DC: $fqdnDC (Discovered) (Status: $connectionResult)" "ERROR"
					}
				}
			} Else {
				#  Check If The Specified RWDC Is Available Or Not
				$connectionResult = portConnectionCheck $fqdnDC 389 500
				If ($connectionResult -eq "SUCCESS") {
					Logging "" "SUCCESS"
					Logging "  --> FQDN DC: $fqdnDC (Static) (Status: $connectionResult)" "SUCCESS"
				} Else {
					Logging "" "ERROR"
					Logging "  --> FQDN DC: $fqdnDC (Static) (Status: $connectionResult)" "ERROR"
				}
			}
			
			# If There Is Something Wrong With The RWDC, Then Abort Processing For This AD Domain And Send Mail About It
			If ($connectionResult -eq "ERROR" -And $fqdnDC -ne "DOMAIN_DOES_NOT_EXIST_OR_CANNOT_FIND_DC") {
				Logging "  --> SKIPPED DUE TO ERROR - DOMAIN EXISTS, BUT UNABLE TO CONTACT DISCOVERED/SPECIFIED DC!" "ERROR"
				$mailSubject = "ERROR: AD Expiry Notification Script: Error With DC '$fqdnDC' From AD Domain '$fqdnADdomain'!"
				$mailIssueLine = "AD Domain '$fqdnADdomain' Exists, But There Are Connectivity Issues With The DC '$fqdnDC'!"
			
				sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine
			}
			If ($connectionResult -eq "ERROR" -And $fqdnDC -eq "DOMAIN_DOES_NOT_EXIST_OR_CANNOT_FIND_DC") {
				Logging "  --> SKIPPED DUE TO ERROR - DOMAIN DOES NOT EXIST OR CANNOT FIND DC!" "ERROR"
				$mailSubject = "ERROR: AD Expiry Notification Script: Error Finding DC For AD Domain '$fqdnADdomain'!"
				$mailIssueLine = "The AD Domain '$fqdnADdomain' Does Not Exist Or Unable To Discover A DC For The AD Domain '$fqdnADdomain'!"
			
				sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine
			}
			
			# If The AD Domain Does Exist, The DC Can Be Discovered And It Can Be Contacted
			If ($connectionResult -eq "SUCCESS") {
				# Array Definition Of All Password Policies In A Domain
				If ($pwdExpiryNotificationEnabled -eq $true) {
					$script:pwdPolicyInDomain = @()

					# Connect To The RootDSE Of The RWDC And Get Info From It
					$rootDSE = $null
					$rootDSE = [ADSI]"LDAP://$fqdnDC/RootDSE"
					$dfl = $null
					$dfl = $rootDSE.domainFunctionality
					$defaultNC = $null
					$defaultNC = $rootDSE.defaultNamingContext
					Logging "" "REMARK"
					Logging "  --> DFL: $dfl ($(decodeFunctionalLevel $dfl))" "REMARK"
					Logging "" "REMARK"
					Logging "  --> Default NC: $defaultNC" "REMARK"
				
					# Get The Password Policy Settings From The Default Domain GPO Which Are Also Registered On The AD Domain NC Head
					Logging "" "HEADER"
					Logging "  --> Default Domain GPO Password Settings For AD Domain '$fqdnADdomain'" "HEADER"
					# Setup The LDAP Query To Get The Password Policy Settings From The Default Domain GPO And Execute The Query
					$searchRoot = $null
					$searchRoot = [ADSI]"LDAP://$fqdnDC/$defaultNC"
					$searcher = $null
					$searcher = New-Object System.DirectoryServices.DirectorySearcher($searchRoot)
					$searcher.SearchScope = "Base"
					$propertyList = "maxPwdAge","minPwdAge","minPwdLength","pwdProperties","pwdHistoryLength","objectSid"
					ForEach ($property in $propertyList){
						$searcher.PropertiesToLoad.Add($property) | Out-Null
					}
					$results = $null
					$results = $searcher.FindOne()
					
					### Get The Properties And Process Them
					If ($results) {
						$results | ForEach-Object{
							$pwdPolicyGPOInDomainObj = $null
							$pwdPolicyGPOInDomainObj = "" | Select-Object DN,name,MaxPwdAge,MinPwdAge,MinPwdLength,PwdComplexity,PwdHistoryLength
							
							# The Distinguished Name
							$pwdPolicyGPOInDomainObj.DN = $defaultNC
							
							# The Name
							$gpoName = "DefaultDomainGPO (" + $fqdnADdomain + ")"
							$pwdPolicyGPOInDomainObj.name = $gpoName
							Logging "" "REMARK"
							Logging "       --> Name............: $gpoName" "REMARK"
							
							# The Max Password Age
							$gpoMaxPwdAge = $null
							$gpoMaxPwdAge = [System.TimeSpan]::FromTicks([System.Math]::ABS($_.Properties.maxpwdage[0])).Days
							If ($gpoMaxPwdAge -notmatch "\d") {
								$gpoMaxPwdAge = "ERROR"
							}
							$pwdPolicyGPOInDomainObj.MaxPwdAge = $gpoMaxPwdAge
							Logging "       --> Max Pwd Age.....: $gpoMaxPwdAge" "REMARK"
							
							# The Min Password Age
							$gpoMinPwdAge = $null
							$gpoMinPwdAge = [System.TimeSpan]::FromTicks([System.Math]::ABS($_.Properties.minpwdage[0])).Days
							If ($gpoMinPwdAge -notmatch "\d") {
								$gpoMinPwdAge = "ERROR"
							}
							$pwdPolicyGPOInDomainObj.MinPwdAge = $gpoMinPwdAge
							Logging "       --> Min Pwd Age.....: $gpoMinPwdAge" "REMARK"
							
							# The Min Password Length
							$gpoMinPwdLength = $null
							$gpoMinPwdLength = $_.Properties.minpwdlength[0]
							If ($gpoMinPwdLength -notmatch "\d") {
								$gpoMinPwdLength = "ERROR"
							}
							$pwdPolicyGPOInDomainObj.MinPwdLength = $gpoMinPwdLength
							Logging "       --> Min Pwd Length..: $gpoMinPwdLength" "REMARK"

							# The Password Complexity
							If (($results.Properties.pwdproperties[0] -band 0x1) -eq 1) {
								$pwdPolicyGPOInDomainObj.PwdComplexity = "TRUE"
								Logging "       --> Pwd Complexity..: TRUE" "REMARK"
							} Else {
								$pwdPolicyGPOInDomainObj.PwdComplexity = "FALSE"
								Logging "       --> Pwd Complexity..: FALSE" "REMARK"
							}

							# The Password History Length
							$gpoPwdHistoryLength = $null
							$gpoPwdHistoryLength = $_.Properties.pwdhistorylength[0]
							If ($gpoPwdHistoryLength -notmatch "\d") {
								$gpoPwdHistoryLength = "ERROR"
							}
							$pwdPolicyGPOInDomainObj.PwdHistoryLength = $gpoPwdHistoryLength
							Logging "       --> Pwd Hist. Length: $gpoPwdHistoryLength" "REMARK"
							$script:pwdPolicyInDomain += $pwdPolicyGPOInDomainObj
						}
					} Else {
							Logging ""
							Logging "       --> Default Domain GPO Was NOT Found" "REMARK"
					}
					$searcher = $null
					$results = $null

					# PWD Policies From The AD Domain
					# If Domain Functional Level Is At Least 3 (Windows 2008) Or Higher Then Check For Any Configured Password Settings Object (PSO) And Get The Settings For Each PSO
					If ($dfl -ge 3) {
						Logging "" "HEADER"
						Logging "  --> PSOs In AD Domain '$fqdnADdomain'" "HEADER"
						
						# PSO Container (REMEMBER: The Account Running This Script Must Have Allow:Read Permissions On The PSO Container Itself And Sub Objects
						$psoContainerDN = "CN=Password Settings Container,CN=System,$defaultNC"
						
						# Setup The LDAP Query To Check Access To The "Password Settings Container" Container And Execute The Query
						# If It Is Possible To Read The Value Of The Constructed Attribute "msDS-Approx-Immed-Subordinates", Access Is Possible Otherwise It Is Denied And Therefore Lacking The Required Permissions
						$searchRoot = $null
						$searchRoot = [ADSI]"LDAP://$fqdnDC/$psoContainerDN"
						$searcher = $null
						$searcher = New-Object System.DirectoryServices.DirectorySearcher($searchRoot)
						$searcher.SearchScope = "Base"
						$propertyList = "msDS-Approx-Immed-Subordinates"
						ForEach ($property in $propertyList){
							$searcher.PropertiesToLoad.Add($property) | Out-Null
						}
						$results = $null
						$psoContainerAccessStatus = $null
						Try {
							$results = $searcher.FindOne()
							Logging "" "SUCCESS"
							Logging "       --> Password Settings Container: '$psoContainerDN' Accessible" "SUCCESS"
							$psoContainerAccessStatus = "SUCCESS"
						} Catch {
							Logging "" "ERROR"
							Logging "       --> Password Settings Container: '$psoContainerDN' NOT Accessible" "ERROR"
							$psoContainerAccessStatus = "ERROR"

							$mailSubject = "ERROR: AD Expiry Notification Script: Error Accessing Password Settings Container In AD Domain '$fqdnADdomain'!"
							$mailIssueLine = "The Account Running The Password Expiration Notification Script DOES NOT Have The Required Access To The Password Settings Objects Container '$psoContainerDN'!`n`nThe Account Running This Script Requires To Have Allow:Read Permissions On The Password Settings Objects Container Itself And Sub Objects!`n`nFor More Information Please Also See: https://jorgequestforknowledge.wordpress.com/2007/08/09/windows-server-2008-fine-grained-password-policies/"
						
							sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine
						}

						# If The "Password Settings Container" Container Is Accessible Then Query For Any PSO
						If ($psoContainerAccessStatus -eq "SUCCESS") {
							### Setup The LDAP Query To Get All PSOs And Execute The Query
							$searchRoot = $null
							$searchRoot = [ADSI]"LDAP://$fqdnDC/$psoContainerDN"
							$searcher = $null
							$searcher = New-Object System.DirectoryServices.DirectorySearcher($searchRoot)
							$searcher.Filter = "(objectClass=msDS-PasswordSettings)"
							$searcher.SearchScope = "Subtree"
							$searcher.PageSize = 1000
							$propertyList = "distinguishedName","name","msDS-MaximumPasswordAge","msDS-MinimumPasswordAge","msDS-MinimumPasswordLength","msDS-PasswordComplexityEnabled","msDS-PasswordHistoryLength"
							ForEach ($property in $propertyList){
								$searcher.PropertiesToLoad.Add($property) | Out-Null
							}
							$results = $null
							$results = $searcher.FindAll()
							
							### For Every Discovered PSO Get Its Properties (REMEMBER: The Account Running This Script Must Have Allow:Read Permissions On The PSO Container Itself And Sub Objects
							If ($results) {
								$results | ForEach-Object{
									$pwdPolicyPSOInDomainObj = $null
									$pwdPolicyPSOInDomainObj = "" | Select-Object DN,name,MaxPwdAge,MinPwdAge,MinPwdLength,PwdComplexity,PwdHistoryLength

									# The Distinguished Name
									$pwdPolicyPSOInDomainObj.DN = $_.Properties.distinguishedname[0]
									
									# The Name
									$psoName = $_.Properties.name[0]
									$pwdPolicyPSOInDomainObj.name = $($psoName + " (" + $fqdnADdomain + ")")
									Logging "" "REMARK"
									Logging "       --> Name............: $psoName" "REMARK"
									
									# The Max Password Age
									$psoMaxPwdAge = $null
									$psoMaxPwdAge = [System.TimeSpan]::FromTicks([System.Math]::ABS($_.Properties."msds-maximumpasswordage"[0])).Days
									If ($psoMaxPwdAge -notmatch "\d") {
										$psoMaxPwdAge = "ERROR"
									}
									$pwdPolicyPSOInDomainObj.MaxPwdAge = $psoMaxPwdAge
									Logging "       --> Max Pwd Age.....: $psoMaxPwdAge" "REMARK"

									# The Min Password Age
									$psoMinPwdAge = $null
									$psoMinPwdAge = [System.TimeSpan]::FromTicks([System.Math]::ABS($_.Properties."msds-minimumpasswordage"[0])).Days
									If ($psoMinPwdAge -notmatch "\d") {
										$psoMinPwdAge = "ERROR"
									}
									$pwdPolicyPSOInDomainObj.MinPwdAge = $psoMinPwdAge
									Logging "       --> Min Pwd Age.....: $psoMinPwdAge" "REMARK"
									
									# The Min Password Length
									$psoMinPwdLength = $null
									$psoMinPwdLength = $_.Properties."msds-minimumpasswordlength"[0]
									If ($psoMinPwdLength -notmatch "\d") {
										$psoMinPwdLength = "ERROR"
									}
									$pwdPolicyPSOInDomainObj.MinPwdLength = $psoMinPwdLength
									Logging "       --> Min Pwd Length..: $psoMinPwdLength" "REMARK"
									
									# The Password Complexity
									If ($_.Properties."msds-passwordcomplexityenabled"[0]) {
										$pwdPolicyPSOInDomainObj.PwdComplexity = "TRUE"
										Logging "       --> Pwd Complexity..: TRUE" "REMARK"
									} Else {
										$pwdPolicyPSOInDomainObj.PwdComplexity = "FALSE"
										Logging "       --> Pwd Complexity..: FALSE" "REMARK"
									}
									
									# The Password History Length
									$psoPwdHistoryLength = $null
									$psoPwdHistoryLength = $_.Properties."msds-passwordhistorylength"[0]
									If ($psoPwdHistoryLength -notmatch "\d") {
										$psoPwdHistoryLength = "ERROR"
									}
									$pwdPolicyPSOInDomainObj.PwdHistoryLength = $psoPwdHistoryLength
									Logging "       --> Pwd Hist. Length: $psoPwdHistoryLength" "REMARK"
									$script:pwdPolicyInDomain += $pwdPolicyPSOInDomainObj
								}
							}
							$searcher = $null
							$results = $null
						}
					}
				}

				# Processing Each Configured Search Base Within An AD Domain In The XML Config File
				Logging "" "HEADER"
				Logging "  --> Search Bases For AD Domain '$fqdnADdomain'" "HEADER"
				$searchBases = $null
				$searchBases = $_.searchBase
				If ($searchBases) {
					$searchBases | ForEach-Object{
						# Determine If "accountExpiryNotification" Is Enabled For The Search Base
						$accountExpiryNotificationEnabledForSearchbase = $null
						$accountExpiryNotificationEnabledForSearchbase = $_.accountExpiryNotificationEnabled

						# Determine If "pwdExpiryNotification" Is Enabled For The Search Base
						$pwdExpiryNotificationEnabledForSearchbase = $null
						$pwdExpiryNotificationEnabledForSearchbase = $_.pwdExpiryNotificationEnabled
						
						# Determine The Distinguished Name Of The Search Base
						$searchBase = $null
						$searchBase = $_."#text"

						# Let's Make Sure The Configured Search Base Does Exist, But Only If Feature Is Enabled Globally And For The Searchbase Itself
						If (($accountExpiryNotificationEnabled -eq $true -And $accountExpiryNotificationEnabledForSearchbase -eq $true) -Or ($pwdExpiryNotificationEnabled -eq $true -And $pwdExpiryNotificationEnabledForSearchbase -eq $true)) {
							# Check And See If The Specified Search Base Exists In AD Domain
							$searchBaseStatus = $null
							$searchBaseStatus = checkDNExistence $fqdnDC $searchBase
							Logging "" "REMARK"
							Logging "       --> Search Base..........: $searchBase (Status: $searchBaseStatus)" "REMARK"
							
							### If The Search Base Does Exist Then Continue
							If ($searchBaseStatus -eq "SUCCESS") {
								# Specific Language For The Search Base
								$languageForUser = $null
								$languageForUser = $_.language

								# Specific Search Scope For The Search Base
								$searchScope = $null
								$searchScope = $_.searchScope

								# The Mail Subject (Specific And Generic) Using A Specific Language To Be Used For "accountExpiryNotification". If The Specific Cannot Be Found, Use The Generic One
								$mailSubjectAccountExpiryNotificationForUserSpecific = ($htmlBodyFiles | Where-Object{$_.language -eq $languageForUser -And $_.featureName -eq "accountExpiryNotification"}).mailSubject
								$mailSubjectAccountExpiryNotificationForUserGeneric = ($htmlBodyFiles | Where-Object{$_.language -eq "Default" -And $_.featureName -eq "accountExpiryNotification"}).mailSubject
								$mailSubjectAccountExpiryNotificationForUser = $null
								$mailSubjectAccountExpiryNotificationForUser = If ($mailSubjectAccountExpiryNotificationForUserSpecific) {$mailSubjectAccountExpiryNotificationForUserSpecific} Else {$mailSubjectAccountExpiryNotificationForUserGeneric}
								
								# The HTML Body File Using A Specific Specified Language To Be Used For "accountExpiryNotification". If The Specific Cannot Be Found, Use The Generic One
								$htmlBodyFileAccountExpiryNotificationForUserSpecific = ($htmlBodyFiles | Where-Object{$_.language -eq $languageForUser -And $_.featureName -eq "accountExpiryNotification"}).htmlBodyFullPath
								$htmlBodyFileAccountExpiryNotificationForUserGeneric = ($htmlBodyFiles | Where-Object{$_.language -eq "Default" -And $_.featureName -eq "accountExpiryNotification"}).htmlBodyFullPath
								$htmlBodyFileAccountExpiryNotificationForUser = $null
								$htmlBodyFileAccountExpiryNotificationForUser = If ($htmlBodyFileAccountExpiryNotificationForUserSpecific) {$htmlBodyFileAccountExpiryNotificationForUserSpecific} Else {$htmlBodyFileAccountExpiryNotificationForUserGeneric}

								# The Picture File Using A Specific Specified Language To Be Used For "accountExpiryNotification". If The Specific Cannot Be Found, Use The Generic One
								$pictureFileAccountExpiryNotificationForUserSpecific = ($htmlBodyFiles | Where-Object{$_.language -eq $languageForUser -And $_.featureName -eq "accountExpiryNotification"}).attachedPictureFullPath
								$pictureFileAccountExpiryNotificationForUserGeneric = ($htmlBodyFiles | Where-Object{$_.language -eq "Default" -And $_.featureName -eq "accountExpiryNotification"}).attachedPictureFullPath
								$pictureFileAccountExpiryNotificationForUser = $null
								$pictureFileAccountExpiryNotificationForUser = If ($pictureFileAccountExpiryNotificationForUserSpecific) {$pictureFileAccountExpiryNotificationForUserSpecific} Else {$pictureFileAccountExpiryNotificationForUserGeneric}

								# The Mail Subject (Specific And Generic) Using A Specific Language To Be Used For "accountExpiryNotification". If The Specific Cannot Be Found, Use The Generic Ons
								$mailSubjectPwdExpiryNotificationForUserSpecific = ($htmlBodyFiles | Where-Object{$_.language -eq $languageForUser -And $_.featureName -eq "pwdExpiryNotification"}).mailSubject
								$mailSubjectPwdExpiryNotificationForUserGeneric = ($htmlBodyFiles | Where-Object{$_.language -eq "Default" -And $_.featureName -eq "pwdExpiryNotification"}).mailSubject
								$mailSubjectPwdExpiryNotificationForUser = $null
								$mailSubjectPwdExpiryNotificationForUser = If ($mailSubjectPwdExpiryNotificationForUserSpecific) {$mailSubjectPwdExpiryNotificationForUserSpecific} Else {$mailSubjectPwdExpiryNotificationForUserGeneric}

								# The Mail Subject (Specific And Generic) Using A Specific Language To Be Used For "pwdExpiryNotification". If The Specific Cannot Be Found, Use The Generic Ons
								$htmlBodyFilePwdExpiryNotificationForUserSpecific = ($htmlBodyFiles | Where-Object{$_.language -eq $languageForUser -And $_.featureName -eq "pwdExpiryNotification"}).htmlBodyFullPath
								$htmlBodyFilePwdExpiryNotificationForUserGeneric = ($htmlBodyFiles | Where-Object{$_.language -eq "Default" -And $_.featureName -eq "pwdExpiryNotification"}).htmlBodyFullPath
								$htmlBodyFilePwdExpiryNotificationForUser = $null
								$htmlBodyFilePwdExpiryNotificationForUser = If ($htmlBodyFilePwdExpiryNotificationForUserSpecific) {$htmlBodyFilePwdExpiryNotificationForUserSpecific} Else {$htmlBodyFilePwdExpiryNotificationForUserGeneric}

								# The Picture File Using A Specific Specified Language To Be Used For "pwdExpiryNotification". If The Specific Cannot Be Found, Use The Generic One
								$pictureFilePwdExpiryNotificationForUserSpecific = ($htmlBodyFiles | Where-Object{$_.language -eq $languageForUser -And $_.featureName -eq "pwdExpiryNotification"}).attachedPictureFullPath
								$pictureFilePwdExpiryNotificationForUserGeneric = ($htmlBodyFiles | Where-Object{$_.language -eq "Default" -And $_.featureName -eq "pwdExpiryNotification"}).attachedPictureFullPath
								$pictureFilePwdExpiryNotificationForUser = $null
								$pictureFilePwdExpiryNotificationForUser = If ($pictureFilePwdExpiryNotificationForUserSpecific) {$pictureFilePwdExpiryNotificationForUserSpecific} Else {$pictureFilePwdExpiryNotificationForUserGeneric}

								### Setup The LDAP Query To Get The User Objects And Execute The Query
								$searchRoot = $null
								$searchRoot = [ADSI]"LDAP://$fqdnDC/$searchBase"
								$searcher = $null
								$searcher = New-Object System.DirectoryServices.DirectorySearcher($searchRoot)
								$searcher.Filter = "(&(objectCategory=person)(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2))(mail=*))"
								$searcher.SearchScope = $searchScope
								$searcher.PageSize = 1000
								$propertyList = "accountExpires","displayName","distinguishedName","givenName","mail","msDS-PrincipalName","msDS-ResultantPSO","msDS-UserPasswordExpiryTimeComputed","pwdLastSet","sAMAccountName","sn","userAccountControl","userPrincipalName"
								ForEach ($property in $propertyList){
									$searcher.PropertiesToLoad.Add($property) | Out-Null
								}
								$results = $null
								$results = $searcher.FindAll()
								$userCountInSearchBase = ($results | Measure-Object).Count
								Logging "       --> Queried User Count...: $userCountInSearchBase" "REMARK"
								Logging "       --> Specified Language...: $languageForUser" "REMARK"
								
								### Get The Properties And Process Them
								If ($results) {
									$results | ForEach-Object{
										$listOfQueriedUsersObj = $null
										$listOfQueriedUsersObj = "" | Select-Object "FQDN AD Domain","NBT AD Domain","Distinguished Name","Given Name","Last Name","Display Name","E-Mail Address","UPN","Sam Account Name","Principal Account Name","SC Required","PWD Never Exp","PWD Last Set","PWD Expire Date","Days Until PWD Expiry","Account Expiry Date","Days Until Account Expiry","Effective PWD Policy","Language","Scoped For Acc Exp Not","Mail Subject (Acc Exp Not)","HTML Body File (Acc Exp Not)","Picture File (Acc Exp Not)","Acc Exp Not","Scoped For Pwd Exp Not","Mail Subject (Pwd Exp Not)","HTML Body File (Pwd Exp Not)","Picture File (Pwd Exp Not)","Pwd Exp Not"
										
										# FQDN AD Domain For The User
										$listOfQueriedUsersObj."FQDN AD Domain" = $fqdnADdomain

										# User Account Control For The User
										$userAccountControl = $null
										$userAccountControl = $_.Properties.useraccountcontrol[0]
										
										# Distinguished Name For The User
										$distinguishedName = $null
										$distinguishedName = $_.Properties.distinguishedname[0]
										$listOfQueriedUsersObj."Distinguished Name" = $distinguishedName
										
										# Given Name For The User
										If ($_.Properties.givenname -ne $null) {
											$givenName = $null
											$givenName = $_.Properties.givenname[0]
											$listOfQueriedUsersObj."Given Name" = $givenName
										} Else {
											$listOfQueriedUsersObj."Given Name" = $null
										}
										
										# Sur Name For The User
										If ($_.Properties.sn -ne $null) {
											$sn = $null
											$sn = $_.Properties.sn[0]
											$listOfQueriedUsersObj."Last Name" = $sn
										} Else {
											$listOfQueriedUsersObj."Last Name" = $null
										}				
										
										# Display Name For The User
										If ($_.Properties.displayname -ne $null) {
											$displayName = $null
											$displayName = $_.Properties.displayname[0]
											$listOfQueriedUsersObj."Display Name" = $displayName
										} Else {
											$listOfQueriedUsersObj."Display Name" = $null
										}
										
										# E-Mail For The User
										$mail = $null
										$mail = $_.Properties.mail[0]
										$listOfQueriedUsersObj."E-Mail Address" = $mail
										
										# UPN For The User
										$upn = $null
										$upn = $_.Properties.userprincipalname[0]
										$listOfQueriedUsersObj."UPN" = $upn

										# sAMAccountName For The User
										$sAMAccountName = $null
										$sAMAccountName = $_.Properties.samaccountname[0]
										$listOfQueriedUsersObj."Sam Account Name" = $sAMAccountName

										# Principal AccountName For The User
										$principalAccountName = $null
										$principalAccountName = $_.Properties."msds-principalname"[0]
										$listOfQueriedUsersObj."Principal Account Name" = $principalAccountName

										# NetBIOS AD Domain For The User
										$listOfQueriedUsersObj."NBT AD Domain" = $listOfQueriedUsersObj."Principal Account Name".SubString(0, $listOfQueriedUsersObj."Principal Account Name".IndexOf("\"))

										# User Account Control Bit "Smart card Required" For The User
										$uac_SMARTCARD_REQUIRED = 262144
										$adUserScRequired = $null
										$adUserScRequired = ($userAccountControl -band $uac_SMARTCARD_REQUIRED) -eq $uac_SMARTCARD_REQUIRED
										$listOfQueriedUsersObj."SC Required" = $adUserScRequired

										# User Account Control Bit "Password Never Expires" For The User
										$uac_DONT_EXPIRE_PASSWORD = 65536
										$adUserPwdNeverExpires = $null
										$adUserPwdNeverExpires = ($userAccountControl -band $uac_DONT_EXPIRE_PASSWORD) -eq $uac_DONT_EXPIRE_PASSWORD
										$listOfQueriedUsersObj."PWD Never Exp" = $adUserPwdNeverExpires
										
										# Password Last Set For The User
										$adUserPwdLastSet = $null
										$adUserPwdLastSet = Get-Date -Date ([DateTime]::FromFileTime([Int64]::Parse($_.Properties.pwdlastset[0]))) -Format $formatDateTime
										$listOfQueriedUsersObj."PWD Last Set" = $adUserPwdLastSet
										
										# Password Expiry Date For The User / Number Of Days Until It Expires
										$adUserPwdExpires = $null
										$adUserPwdExpires = $_.Properties."msds-userpasswordexpirytimecomputed"[0]
										If ($adUserPwdExpires -eq 9223372036854775807 -Or $adUserPwdExpires -eq 0) {
											$adUserPwdExpires = Get-Date "9999-12-31 23:59:59" -format $formatDateTime
										} Else {
											$adUserPwdExpires = Get-Date -Date ([DateTime]::FromFileTime([Int64]::Parse($adUserPwdExpires))) -Format $formatDateTime
										}
										$listOfQueriedUsersObj."PWD Expire Date" = $adUserPwdExpires
										$timeDiffPwdExpiryInDays = $null
										$timeDiffPwdExpiryInDays = (New-TimeSpan -Start $execStartDateTime -end $adUserPwdExpires).TotalDays
										$listOfQueriedUsersObj."Days Until PWD Expiry" = $timeDiffPwdExpiryInDays
										
										# Account Expiry Date For The User / Number Of Days Until It Expires
										$adUserAccountExpires = $null
										$adUserAccountExpires = $_.Properties.accountexpires[0]
										# If An Account Is Configured With Never Expires, Then Assign An Insane End Date To Be Able To Perform Calculations
										If ($adUserAccountExpires -eq 9223372036854775807 -Or $adUserAccountExpires -eq 0) {
											$adUserAccountExpires = Get-Date "9999-12-31 23:59:59" -format $formatDateTime
										} Else {
											$adUserAccountExpires = Get-Date -Date ([DateTime]::FromFileTime([Int64]::Parse($adUserAccountExpires))) -Format $formatDateTime
										}
										$listOfQueriedUsersObj."Account Expiry Date" = $adUserAccountExpires
										$timeDiffAccountExpiryInDays = $null
										$timeDiffAccountExpiryInDays = (New-TimeSpan -Start $execStartDateTime -end $adUserAccountExpires).TotalDays
										$listOfQueriedUsersObj."Days Until Account Expiry" = $timeDiffAccountExpiryInDays
										
										# DN Of Effective/Resultant Password Policy
										$effectivePWDPolicyDN = $null
										If ($_.Properties."msds-resultantpso" -ne $null) {
											$effectivePWDPolicyDN = $_.Properties."msds-resultantpso"[0]
										} Else {
											$effectivePWDPolicyDN = $defaultNC
										}
										$effectivePWDPolicyName = $null
										$effectivePWDPolicyName = ($pwdPolicyInDomain | Where-Object{$_.DN -eq $effectivePWDPolicyDN}).name
										$listOfQueriedUsersObj."Effective PWD Policy" = $effectivePWDPolicyName
										
										# Language For The User Based Upon The Search Base
										$listOfQueriedUsersObj."Language" = $null
										$listOfQueriedUsersObj."Language" = $languageForUser

										# Whether Or Not The User Account Is Scoped For Account Expiry Notification
										$listOfQueriedUsersObj."Scoped For Acc Exp Not" = $null
										$listOfQueriedUsersObj."Scoped For Acc Exp Not" = $($accountExpiryNotificationEnabled -eq $true -And $accountExpiryNotificationEnabledForSearchbase -eq $true)
										
										# The Mail Subject To Be Used For Eventual Account Expiry Notification If Applicable
										$listOfQueriedUsersObj."Mail Subject (Acc Exp Not)" = $null
										$listOfQueriedUsersObj."Mail Subject (Acc Exp Not)" = $mailSubjectAccountExpiryNotificationForUser
										
										# The HTML Body File To Be Used For Eventual Account Expiry Notification If Applicable
										$listOfQueriedUsersObj."HTML Body File (Acc Exp Not)" = $null
										$listOfQueriedUsersObj."HTML Body File (Acc Exp Not)" = $htmlBodyFileAccountExpiryNotificationForUser
										
										# The Picture File To Be Used For Eventual Account Expiry Notification If Applicable
										$listOfQueriedUsersObj."Picture File (Acc Exp Not)" = $null
										$listOfQueriedUsersObj."Picture File (Acc Exp Not)" = $pictureFileAccountExpiryNotificationForUser

										# Initial State The User Will Not Be Notified - This May Change Later Due To Conditions!
										$listOfQueriedUsersObj."Acc Exp Not" = $false
										
										# Whether Or Not The User Account Is Scoped For Password Expiry Notification
										$listOfQueriedUsersObj."Scoped For Pwd Exp Not" = $null
										$listOfQueriedUsersObj."Scoped For Pwd Exp Not" = $($pwdExpiryNotificationEnabled -eq $true -And $pwdExpiryNotificationEnabledForSearchbase -eq $true)
										
										# The Mail Subject To Be Used For Eventual Password Expiry Notification If Applicable
										$listOfQueriedUsersObj."Mail Subject (Pwd Exp Not)" = $null
										$listOfQueriedUsersObj."Mail Subject (Pwd Exp Not)" = $mailSubjectPwdExpiryNotificationForUser
										
										# The HTML Body File To Be Used For Eventual Password Expiry Notification If Applicable
										$listOfQueriedUsersObj."HTML Body File (Pwd Exp Not)" = $null
										$listOfQueriedUsersObj."HTML Body File (Pwd Exp Not)" = $htmlBodyFilePwdExpiryNotificationForUser

										# The Picture File To Be Used For Eventual Account Expiry Notification If Applicable
										$listOfQueriedUsersObj."Picture File (Pwd Exp Not)" = $null
										$listOfQueriedUsersObj."Picture File (Pwd Exp Not)" = $pictureFilePwdExpiryNotificationForUser

										# Initial State The User Will Not Be Notified - This May Change Later Due To Conditions!
										$listOfQueriedUsersObj."Pwd Exp Not" = $false

										$listOfQueriedUsers += $listOfQueriedUsersObj
									}
								}
								$searcher = $null
								$results = $null
							} Else {
								### If The Search Base Does NOT Exist Then Skip That Search Base And Send Mail About It
								Logging "       --> SKIPPED DUE TO ERROR!" "ERROR"
								$mailSubject = "ERROR: AD Expiry Notification Script: Error With Defined SearchBase!"
								$mailIssueLine = "The Search Base '$searchBase' Does Not Exist In The AD Domain '$fqdnADdomain'!"
							
								sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine
							}
						}
					}
				} Else {
					Logging "" "WARNING"
					Logging "       --> The XML File Does NOT Specify Any Search Bases For The AD Domain '$fqdnADdomain'" "WARNING"
				}
			}
		}

		Logging ""
		Logging "------------------------------------------------------------------------------------------------------------------------------------" "HEADER"
		### Now Having The List Of Queried Users, Determine Which Of Those Users Require E-mail Notification Based Upon The Enabled Features And The Configured Warning Periods
		Logging "" "HEADER"
		Logging "Processing And Checking The Scoped List Of Users Against Warning Periods..." "HEADER"

		# Only If A List Of Queried Users Exists, Process Those
		$listOfUsersToNotify = @()
		If ($listOfQueriedUsers) {
			# Defining The Counters
			$iNrTotal = 0
			$iNrNotScopedForAnyNotification = 0
			$iNrNotScopedForAccountExpiryNotification = 0
			$iNrNotScopedForPwdExpiryNotification = 0
			$iNrScopedForAnyNotification = 0
			$iNrScopedForAccountExpiryNotification = 0
			$iNrScopedForPwdExpiryNotification = 0

			# Process Every User In The Queried List
			$listOfQueriedUsers | ForEach-Object{
				# Increase The Counter
				$iNrTotal++
				
				# The User Object To Be Processed
				$queriedUserObj = $null
				$queriedUserObj = $_

				# UPN For The User
				$upn = $null
				$upn = $queriedUserObj.UPN

				# E-Mail For The User
				$mail = $null
				$mail = $queriedUserObj."E-Mail Address"
				
				# Number Of Days Until Account Expires
				$daysUntilAccountExpiry = $null
				$daysUntilAccountExpiry = $queriedUserObj."Days Until Account Expiry"

				# Number Of Days Until Password Expires
				$daysUntilPwdExpiry = $null
				$daysUntilPwdExpiry = $queriedUserObj."Days Until PWD Expiry"

				Logging "" "REMARK"
				Logging " > User: UPN = $upn | E-Mail = $mail" "REMARK"

				# Only When An Account Is A Scoped Candidate For Account Expiration Notification And Its Number Of Days Until The Account Expires Is Greater Than Zero
				If ($queriedUserObj."Scoped For Acc Exp Not" -eq $true -And $daysUntilAccountExpiry -gt 0) {
					($daysBeforeWarn | Where-Object{$_.name -eq "accountExpiryNotification"}).period | Sort-Object -Property nr | ForEach-Object{
						$max = $null
						$max = $_.max
						$minOrEqual = $null
						$minOrEqual = $_.MinOrEqual

						# Only When The Number Of Days Until The Account Expires Is Lower Than The Max Value And Greater Than Or Equal To The Min Value
						If ($daysUntilAccountExpiry -lt $max -And $daysUntilAccountExpiry -ge $minOrEqual) {
							$iNrScopedForAccountExpiryNotification++
							$queriedUserObj."Acc Exp Not" = $true
							Logging "   * Scoped For 'accountExpiryNotification' | Account Expires In: $daysUntilAccountExpiry Days | Warn Period: Max: $max Days & MinOrEqual: $minOrEqual Days" "ACTION"
						}
					}
					If ($queriedUserObj."Acc Exp Not" -eq $false) {
						$iNrNotScopedForAccountExpiryNotification++
						Logging "   * NOT Scoped For 'accountExpiryNotification'" "WARNING"
					}
				} Else {
					$iNrNotScopedForAccountExpiryNotification++
					Logging "   * NOT Scoped For 'accountExpiryNotification'" "WARNING"
				}
				
				# Only When An Account Is A Scoped Candidate For Password Expiration Notification, And Number Of Days Until The Account Expires Is Greater Than Zero, And SmartCard Required Is Not Enabled, And Password Never Expires Is not Enabled And Number Of Days Until The Account Expires Is Greater Than Zero
				If ($queriedUserObj."Scoped For Pwd Exp Not" -eq $true -And $queriedUserObj."Days Until Account Expiry" -gt 0 -And $queriedUserObj."SC Required" -eq $false -And $queriedUserObj."PWD Never Exp" -eq $false -And $queriedUserObj."Days Until PWD Expiry" -gt 0) {
					($daysBeforeWarn | Where-Object{$_.name -eq "pwdExpiryNotification"}).period | Sort-Object -Property nr | ForEach-Object{
						$max = $null
						$max = $_.max
						$minOrEqual = $null
						$minOrEqual = $_.MinOrEqual

						# Only When The Number Of Days Until The Password Expires Is Lower Than The Max Value And Greater Than Or Equal To The Min Value
						If ($daysUntilPwdExpiry -lt $max -And $daysUntilPwdExpiry -gt $minOrEqual) {
							$iNrScopedForPwdExpiryNotification++
							$queriedUserObj."Pwd Exp Not" = $true
							Logging "   * Scoped For 'pwdExpiryNotification' | Password Expires In: $daysUntilPwdExpiry Days | Warn Period: Max: $max Days & MinOrEqual: $minOrEqual Days" "ACTION"
						}
					}
					If ($queriedUserObj."Pwd Exp Not" -eq $false) {
						$iNrNotScopedForPwdExpiryNotification++
						Logging "   * NOT Scoped For 'pwdExpiryNotification'" "WARNING"
					}
				} Else {
					$iNrNotScopedForPwdExpiryNotification++
					Logging "   * NOT Scoped For 'pwdExpiryNotification'" "WARNING"
				}

				# If Either Or Both Account Expiry Notification And/Or Password Expiry Notification Has Been Set To TRUE, Add It To The List Of Users That Will Be Notified For Either Or Both
				If ($queriedUserObj."Acc Exp Not" -eq $true -Or $queriedUserObj."Pwd Exp Not" -eq $true) {
					$iNrScopedForAnyNotification++
					$listOfUsersToNotify += $queriedUserObj
				} Else {
					$iNrNotScopedForAnyNotification++
				}
			}
			
			Logging "" "REMARK"
			Logging "" "REMARK"
			Logging "Total Count Of Processed User Accounts..............................: $iNrTotal" "REMARK"
			Logging "Total Count Of User Accounts NOT Scoped For Any Notification........: $iNrNotScopedForAnyNotification" "REMARK"
			Logging "Total Count Of User Accounts NOT Scoped For Account Notification....: $iNrNotScopedForAccountExpiryNotification" "REMARK"
			Logging "Total Count Of User Accounts NOT Scoped For Password Notification...: $iNrNotScopedForPwdExpiryNotification" "REMARK"
			Logging "Total Count Of User Accounts Scoped For Any Notification............: $iNrScopedForAnyNotification" "REMARK"
			Logging "Total Count Of User Accounts Scoped For Account Notification........: $iNrScopedForAccountExpiryNotification" "REMARK"
			Logging "Total Count Of User Accounts Scoped For Password Notification.......: $iNrScopedForPwdExpiryNotification" "REMARK"
		} Else {
			Logging "" "WARNING"
			Logging " > List Of Queried Users Is Empty. Nothing To Do..." "WARNING"
		}

		### If It Was Configured To Export The List Of Users That Will Be Notified, And There Is A List To Export, Than Do So!
		If ($exportToCSV.ToUpper() -eq "ON" -And $listOfUsersToNotify) {
			$listOfUsersToNotify | Export-Csv -Path $csvFilePath -NoTypeInformation
		}

		Logging "" "REMARK"
		Logging "------------------------------------------------------------------------------------------------------------------------------------" "HEADER"
		### Show On Screen The List Of Users That Will Be Notified, Including Some Details
		Logging "" "HEADER"
		Logging "List Of Notified Users..." HEADER
		If ($listOfUsersToNotify) {
			$listOfUsersToNotify | Format-Table "FQDN AD Domain","NBT AD Domain","Distinguished Name","Given Name","Last Name","Display Name","E-Mail Address","UPN","Sam Account Name","Principal Account Name","SC Required","PWD Never Exp","PWD Last Set","PWD Expire Date","Days Until PWD Expiry","Account Expiry Date","Days Until Account Expiry","Effective PWD Policy","Language","Acc Exp Not","Pwd Exp Not" -Autosize -Wrap

			$userCountNotified = ($listOfUsersToNotify | Measure-Object).Count
			Logging " --> User Count To Be Notified...: $userCountNotified" "REMARK"
	
			### If The FORCE Parameter Was NOT Specified With TRUE Then DO NOT Send Any E-Mail
			If ($executionMode.ToUpper() -eq "TEST (NO MAILINGS)") {
				Logging "" "REMARK"
				Logging "  --> Except For Any Possible Errors Discovered, No Notifications Have Been Send About Password Notifications!" "REMARK"
			} Else {
				### When Running In DEV Mode Execute This Part
				### DEV MODE: 1x Mail To Admin User Only
				If ($executionMode.ToUpper() -eq "DEV") {
					Logging "" "REMARK"
					Logging "------------------------------------------------------------------------------------------------------------------------------------" "HEADER"
					Logging "" "ACTION"
					Logging "Displaying Information Of The Development User..." "ACTION"
					
					### Discover A GC For The Current AD Forest
					$fqdnGC = $null
					$fqdnGC = discoverGC
	
					### Check If The GC Is Available
					If ($fqdnGC -eq "CANNOT_FIND_GC") {
						$connectionResult = "ERROR"
						Logging "" "ERROR"
						Logging "  --> FQDN GC: $fqdnGC (Discovered) (Status: $connectionResult)" "ERROR"
					} Else {
						$connectionResult = $null
						$connectionResult = portConnectionCheck $fqdnGC 3268 500
						If ($connectionResult -eq "SUCCESS") {
							Logging "" "SUCCESS"
							Logging "  --> FQDN GC: $fqdnGC (Discovered) (Status: $connectionResult)" "SUCCESS"
						} Else {
							Logging "" "ERROR"
							Logging "  --> FQDN GC: $fqdnGC (Discovered) (Status: $connectionResult)" "ERROR"
						}
					}
	
					### If There Is Something Wrong With The GC, Then Abort Processing Send Mail About It
					If ($connectionResult -eq "ERROR" -And $fqdnGC -ne "CANNOT_FIND_GC") {
						Logging "  --> SKIPPED DUE TO ERROR - UNABLE TO CONTACT GC!" "ERROR"
						$mailSubject = "ERROR: AD Expiry Notification Script: Error With GC '$fqdnGC'!"
						$mailIssueLine = "There Are Connectivity Issues With The GC '$fqdnGC'!"
					
						sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine
					}
					If ($connectionResult -eq "ERROR" -And $fqdnGC -eq "CANNOT_FIND_GC") {
						Logging "  --> SKIPPED DUE TO ERROR - CANNOT FIND GC!" "ERROR"
						$mailSubject = "ERROR: AD Expiry Notification Script: Error Finding GC!"
						$mailIssueLine = "Unable To Discover A GC!"
					
						sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine
					}
	
					### If The GC Can Be Discovered And It Can Be Contacted
					If ($connectionResult -eq "SUCCESS") {
						### Setup The LDAP Query To Get The Information Of The User And Execute The Query
						$searchRoot = $null
						$searchRoot = [ADSI]"GC://$fqdnGC" # Using The Phantom Root
						$searcher = $null
						$searcher = New-Object System.DirectoryServices.DirectorySearcher($searchRoot)
						$searcher.Filter = "(&(objectCategory=person)(objectClass=user)(`|(proxyAddresses=smtp:$toSMTPAddressInTestMode)(proxyAddresses=SMTP:$toSMTPAddressInTestMode)))"
						$searcher.SearchScope = "Subtree"
						$searcher.PageSize = 1000
						$propertyList = "distinguishedName"
						ForEach ($property in $propertyList){
							$searcher.PropertiesToLoad.Add($property) | Out-Null
						}
						$results = $null
						$results = $searcher.FindOne()
						If ($results) {
							$dnOfObjectForDevTestMode = $null
							$dnOfObjectForDevTestMode = $results.Properties.distinguishedname[0]
							$fqdnADdomainOfObjectForDevTestMode = $null
							$fqdnADdomainOfObjectForDevTestMode = $($dnOfObjectForDevTestMode.Substring($dnOfObjectForDevTestMode.IndexOf("DC=") + 3).Replace(",DC=","."))

							# Discover The Nearest RWDC And Use That One
							$fqdnDC = $null
							$fqdnDC = discoverRWDC $fqdnADdomainOfObjectForDevTestMode
							# Check If The RWDC Is Available
							If ($fqdnDC -eq "DOMAIN_DOES_NOT_EXIST_OR_CANNOT_FIND_DC") {
								$connectionResult = "ERROR"
								Logging "" "ERROR"
								Logging "  --> FQDN DC: $fqdnDC (Discovered) (Status: $connectionResult)" "ERROR"
							} Else {
								$connectionResult = $null
								$connectionResult = portConnectionCheck $fqdnDC 389 500
								If ($connectionResult -eq "SUCCESS") {
									Logging "" "SUCCESS"
									Logging "  --> FQDN DC: $fqdnDC (Discovered) (Status: $connectionResult)" "SUCCESS"
								} Else {
									Logging "" "ERROR"
									Logging "  --> FQDN DC: $fqdnDC (Discovered) (Status: $connectionResult)" "ERROR"
								}
							}
							
							# If There Is Something Wrong With The RWDC, Then Abort Processing For This AD Domain And Send Mail About It
							If ($connectionResult -eq "ERROR" -And $fqdnDC -ne "DOMAIN_DOES_NOT_EXIST_OR_CANNOT_FIND_DC") {
								Logging "  --> SKIPPED DUE TO ERROR - UNABLE TO CONTACT DC!" "ERROR"
								$mailSubject = "ERROR: AD Expiry Notification Script: Error With DC '$fqdnDC' From AD Domain '$fqdnADdomain'!"
								$mailIssueLine = "There Are Connectivity Issues With The DC '$fqdnDC' From The AD Domain '$fqdnADdomain'!"
							
								sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine
							}
							If ($connectionResult -eq "ERROR" -And $fqdnDC -eq "DOMAIN_DOES_NOT_EXIST_OR_CANNOT_FIND_DC") {
								Logging "  --> SKIPPED DUE TO ERROR - DOMAIN DOES NOT EXIST OR CANNOT FIND DC!" "ERROR"
								$mailSubject = "ERROR: AD Expiry Notification Script: Error Finding DC For AD Domain '$fqdnADdomain'!"
								$mailIssueLine = "The AD Domain '$fqdnADdomain' Does Not Exist Or Unable To Discover A DC For The AD Domain '$fqdnADdomain'!"
							
								sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine
							}
							
							### If The AD Domain Does Exist And The DC Can Be Discovered And It Can Be Contacted
							If ($connectionResult -eq "SUCCESS") {
								### Setup The LDAP Query To Get The Information Of The User And Execute The Query
								$rootDSE = $NULL
								$rootDSE = [ADSI]"LDAP://$fqdnDC/RootDSE"
								$defaultNC = $NULL
								$defaultNC = $rootDSE.defaultNamingContext
								$searchRoot = $NULL
								$searchRoot = [ADSI]"LDAP://$fqdnDC/$defaultNC"
								$searcher = $NULL
								$searcher = New-Object System.DirectoryServices.DirectorySearcher($searchRoot)
								$searcher.Filter = "(&(objectCategory=person)(objectClass=user)(`|(proxyAddresses=smtp:$toSMTPAddressInTestMode)(proxyAddresses=SMTP:$toSMTPAddressInTestMode)))"
								$searcher.SearchScope = "Subtree"
								$searcher.PageSize = 1000
								$propertyList = "accountExpires","displayName","distinguishedName","givenName","mail","msDS-PrincipalName","msDS-ResultantPSO","msDS-UserPasswordExpiryTimeComputed","pwdLastSet","sAMAccountName","sn","userAccountControl","userPrincipalName"
								ForEach ($property in $propertyList){
									$searcher.PropertiesToLoad.Add($property) | Out-Null
								}
								$results = $NULL
								$results = $searcher.FindOne()
		
								### Get The Properties Of The User
								If ($results) {
									$devTestUserObj = $null
									$devTestUserObj = "" | Select-Object "FQDN AD Domain","NBT AD Domain","Distinguished Name","Given Name","Last Name","Display Name","E-Mail Address","UPN","Sam Account Name","Principal Account Name","PWD Last Set","PWD Expire Date","Days Until PWD Expiry","Account Expiry Date","Days Until Account Expiry","Effective PWD Policy","Language","Mail Subject (Acc Exp Not)","HTML Body File (Acc Exp Not)","Picture File (Acc Exp Not)","Mail Subject (Pwd Exp Not)","HTML Body File (Pwd Exp Not)","Picture File (Pwd Exp Not)"
									$devTestUserObj."FQDN AD Domain" = $fqdnADdomainOfObjectForDevTestMode
									$userAccountControl = $null
									$userAccountControl = $results.Properties.useraccountcontrol[0]
									$devTestUserObj."Distinguished Name" = $results.Properties.distinguishedname[0]
									$devTestUserObj."Given Name" = If ($null -ne $results.Properties.givenname) {$results.Properties.givenname[0]} Else {"NO-VALUE-FOR-GIVEN-NAME"}
									$devTestUserObj."Last Name" = If ($null -ne $results.Properties.sn) {$results.Properties.sn[0]} Else {"NO-VALUE-FOR-SN"}
									$devTestUserObj."Display Name" = If ($null -ne $results.Properties.displayname) {$results.Properties.displayname[0]} Else {"NO-VALUE"}
									$devTestUserObj."E-Mail Address" = $results.Properties.mail[0]
									$devTestUserObj."UPN" = $results.Properties.userprincipalname[0]
									$devTestUserObj."Sam Account Name" = $results.Properties.samaccountname[0]
									$devTestUserObj."Principal Account Name" = $results.Properties."msds-principalname"[0]
									$devTestUserObj."NBT AD Domain" = $devTestUserObj."Principal Account Name".SubString(0, $devTestUserObj."Principal Account Name".IndexOf("\"))
									$devTestUserObj."PWD Last Set" = Get-Date -Date ([DateTime]::FromFileTime([Int64]::Parse($results.Properties.pwdlastset[0]))) -Format $formatDateTime
									$devTestUserObj."PWD Expire Date" = If ($results.Properties."msds-userpasswordexpirytimecomputed"[0] -eq 9223372036854775807 -Or $results.Properties."msds-userpasswordexpirytimecomputed"[0] -eq 0) {Get-Date "9999-12-31 23:59:59" -format $formatDateTime} Else {Get-Date -Date ([DateTime]::FromFileTime([Int64]::Parse($results.Properties."msds-userpasswordexpirytimecomputed"[0]))) -Format $formatDateTime}
									$devTestUserObj."Days Until PWD Expiry" = (New-TimeSpan -Start $execStartDateTime -end $($devTestUserObj."PWD Expire Date")).TotalDays
									$devTestUserObj."Account Expiry Date" = If ($($results.Properties.accountexpires[0]) -eq 9223372036854775807 -Or $($results.Properties.accountexpires[0]) -eq 0) {Get-Date "9999-12-31 23:59:59" -format $formatDateTime} Else {Get-Date -Date ([DateTime]::FromFileTime([Int64]::Parse($results.Properties.accountexpires[0]))) -Format $formatDateTime}
									$devTestUserObj."Days Until Account Expiry" = (New-TimeSpan -Start $execStartDateTime -end $($devTestUserObj."Account Expiry Date")).TotalDays
									$devTestUserObj."Effective PWD Policy" = ($pwdPolicyInDomain | Where-Object{$_.DN -eq $(If ($results.Properties."msds-resultantpso" -ne $null) {$results.Properties."msds-resultantpso"[0]} Else {$defaultNC})}).name
									$devTestUserObj."Language" = "Default"
									$devTestUserObj."Mail Subject (Acc Exp Not)" = ($htmlBodyFiles | Where-Object{$_.language -eq $($devTestUserObj."Language") -And $_.featureName -eq "accountExpiryNotification"}).mailSubject
									$devTestUserObj."HTML Body File (Acc Exp Not)" = ($htmlBodyFiles | Where-Object{$_.language -eq $($devTestUserObj."Language") -And $_.featureName -eq "accountExpiryNotification"}).htmlBodyFullPath
									$devTestUserObj."Picture File (Acc Exp Not)" = ($htmlBodyFiles | Where-Object{$_.language -eq $($devTestUserObj."Language") -And $_.featureName -eq "accountExpiryNotification"}).attachedPictureFullPath
									$devTestUserObj."Mail Subject (Pwd Exp Not)" = ($htmlBodyFiles | Where-Object{$_.language -eq $($devTestUserObj."Language") -And $_.featureName -eq "pwdExpiryNotification"}).mailSubject
									$devTestUserObj."HTML Body File (Pwd Exp Not)" = ($htmlBodyFiles | Where-Object{$_.language -eq $($devTestUserObj."Language") -And $_.featureName -eq "pwdExpiryNotification"}).htmlBodyFullPath
									$devTestUserObj."Picture File (Pwd Exp Not)" = ($htmlBodyFiles | Where-Object{$_.language -eq $($devTestUserObj."Language") -And $_.featureName -eq "pwdExpiryNotification"}).attachedPictureFullPath

									# If The Feature "accountExpiryNotification" Is Enabled Globally, Then Send The Required E-Mail For The Scoped User To The Recipient
									If ($accountExpiryNotificationEnabled -eq $true) {
										sendEmailDueToExpiration $devTestUserObj "accountExpiryNotification" $toSMTPAddressInTestMode
									}
			
									# If The Feature "pwdExpiryNotification" Is Enabled Globally, Then Send The Required E-Mail For The Scoped User To The Recipient
									If ($pwdExpiryNotificationEnabled -eq $true) {
										sendEmailDueToExpiration $devTestUserObj "pwdExpiryNotification" $toSMTPAddressInTestMode
									}
								} Else {
									Logging "" "ERROR"
									Logging " > Unable To Find The User '$toSMTPAddressInTestMode' In The AD Domain '$fqdnADdomainOfObjectForDevTestMode'..." "ERROR"
								}
							}
						} Else {
							Logging "" "ERROR"
							Logging " > Unable To Find The User '$toSMTPAddressInTestMode' In The Global Catalog..." "ERROR"
						}
					}
				} Else {
					### When Running In TEST Or PROD Mode Execute This Part
					### TEST MODE: All Mails To Support Address Specified In The XML
					### PROD MODE: Each Mails To Individual Users
					### Process Any User With Expiring Account And/Or Password And Send E-Mail Notification About That
					If ($listOfUsersToNotify) {
						$listOfUsersToNotify | ForEach-Object{
							$user = $null
							$user = $_
							### If The FORCE Parameter Was Specified With TRUE Then Send E-Mail Based On The Configured Execution Mode
							If ($executionMode.ToUpper() -eq "TEST") {
								### For All Users Send E-Mail Notifications To The Configured Admin Mail Address
								$mailToRecipient = $toSMTPAddressInTestMode
							}
							If ($executionMode.ToUpper() -eq "PROD") {
								### For All Users Send E-Mail Notifications To The E-Mail Address Of Each User
								$mailToRecipient = $user."E-Mail Address"
							}

							# If The Feature "accountExpiryNotification" Is Enabled Globally, Then Send The Required E-Mail For The Scoped User To The Recipient
							If ($accountExpiryNotificationEnabled -eq $true -And $user."Acc Exp Not" -eq $true) {
								sendEmailDueToExpiration $user "accountExpiryNotification" $mailToRecipient
							}
	
							# If The Feature "pwdExpiryNotification" Is Enabled Globally, Then Send The Required E-Mail For The Scoped User To The Recipient
							If ($pwdExpiryNotificationEnabled -eq $true -And $user."Pwd Exp Not" -eq $true) {
								sendEmailDueToExpiration $user "pwdExpiryNotification" $mailToRecipient
							}
						}
					}
				}
			}
		} Else {
			Logging "" "WARNING"
			Logging " > List Of Users To Notify Is Empty. Nothing To Do..." "WARNING"
		}
	} Else {
		Logging "" "WARNING"
		Logging " > No AD Domains Have Been Specified To Querty For Users. Nothing To Do..." "WARNING"
	}
} Else {
	Logging "" "WARNING"
	Logging "None Of The Features Is Enabled In The XML Config File" "WARNING"
	$mailSubject = "ERROR: AD Expiry Notification Script: No Feature Enabled!"
	$mailIssueLine = "Within the XML Config File '$scriptXMLConfigFilePath' none of the available features has been enabled"

	sendEmailDueToIssue $toSMTPAddressSupport $mailSubject $mailIssueLine

	Logging "" "WARNING"
	Logging "Aborting Script!..." "WARNING"
	Logging "" "WARNING"
}

Logging "" "REMARK"
Logging "" "REMARK"