

      $name=read-host -prompt "First Name?"
	  
	  $last=read-host -prompt "Last Name?"

      $Phone=read-host -prompt "Phone Number?"
	  
      $Password=read-host -prompt "Password?" -AsSecureString
	  
      $DisplayName = "$Name $last"
	  
      $FirstNameInit=$name

      $FirstNameInit=$FirstNameInit.substring(0,1)
	  
	  $alias=$firstnameinit$last
	  
	  $user=$alias
	  
      $DeptNumber=read-host -prompt "Client Code?"
	  
//Select URL from Client Code
      switch -regex ($DeptNumber)
	  {
		"[p2p]" {$clienturl="power2practice.com"}
		"[dgr]" {$clienturl=dgrlegal.com}
		"[acb]" {$clienturl=acbanet.org}
		"[pfs]" {$clienturl="pfs-llc.net"}
		"[sfc]" {$clienturl=sfcasa.org}
		"[hsc]" {$clienturl=hearingspeech.org}
		"[toe]" {$clienturl=toeroek.com}
		"[abs]" {$clienturl=absnorthbay.com}
        "[sym]" {$clienturl=symbiosystems.com}
        "[dnc]" {$clienturl=cunningham-md.com}
				}

	  $userprincipalname="$alias@$clienturl"

      $suffix="TEMPLATE"

      $tmplateUser=read-host -prompt "User to copy groups from?"

      $templateDN=Get-ADUser $tmplateUser | select *,@{l='Parent';e={([adsi]"LDAP://$($_.DistinguishedName)").Parent}}

                             

       new-mailbox -name $DisplayName -alias $alias -Firstname $name -LastName $last -userPrincipalName $userprincipalname -OrganizationalUnit $templateDN -Password $Password


//The following function is used to create the home shared folders:

function CreateHomeDir

{

   Param([string]$user)

   $shareName="$user"

   $Type=0

   $pathToShare="\\$clienturl\home\$user"

   New-Item -type directory -path $pathToShare|Out-Null

   $WMI=[wmiClass]"\\$clienturl\root\cimV2:Win32_Share"

   $WMI.Create($shareName,$Type)|Out-Null

}

//As mentioned earlier, each departmental organizational unit contains a template account with the appropriate security group membership for that department. We use the template account to copy the group membership to the newly created user account. I use the Quest Active Directory tools (the Quest.ActiveRoles.ADManagement add-in), but the script can be easily modified to use the Active Directory module. The function is shown here:

function set-Attributes

{

   Param(

      [string]$user,

      [string]$tmplateUser

   )

 

   AddToCompanyWideGroup -user $user



   $groups=Get-ADUser -Identity $tmplateUser -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $alias

}

//Now we need to set the appropriate permission for the home folder.

function SetSharePerm

{

   Param([string]$user)

   $shareName="\\$clienturl\home\$user"

   $userName="$clienturl\$user"

   $SUBINACL='c:\subinacl.exe'

   &$SUBINACL /Share $shareName /grant=$userName=C |Out-Null

}

//Finally, we will send an email to the Help Desk to notify them that the accounts have been created.
//not required at the moment
//function mailit {
//
//Param(
//
//[string]$user,
//
//[string]$FirstName,
//
//[string]$LastName
//
//)
//
//$EmailList="helpdesk@acme.org"
//
//$MailMessage= @{
//
//To=$EmailList
//
//From="DONOTREPLY@acme.org"
//
//Subject="NEW USER ACCorganizational unitNT"
//
//Body="A new user account has been created. Initial login information listed below: `n
//
//First name: $FirstName
//
//Last name:  $LastName
//
//Userid: $user
//
//Password: letmein
//
//Thank You."
//
//SmtpServer="smtp.acme.org"
//
//ErrorAction="Stop"
//
//            }
//
//Send-MailMessage @MailMessage
//
//}