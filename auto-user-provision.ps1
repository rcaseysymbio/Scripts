

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
				}

	  $userprincipalname="$alias@$clienturl"

      $suffix="TEMPLATE"

      $tmplateUser=read-host -prompt "User to copy groups from?"

      $templateDN=Get-ADUser $tmplateUser | select *,@{l='Parent';e={([adsi]"LDAP://$($_.DistinguishedName)").Parent}}

                       
				
      switch -regex ($LastNameInit)

      {

         "[A]" {$Database="ACMEMX02\6th Storage Group\A Mailboxes"}

         "[B]" {$Database="ACMEMX02\7th Storage Group\B Mailboxes"}

         "[E]" {$Database="ACMEMX02\10th Storage Group\E Mailboxes"}

         "[F]" {$Database="ACMEMX02\11th Storage Group\F Mailboxes"}

         "[G]" {$Database="ACMEMX02\12th Storage Group\G Mailboxes"}

         "[S]" {$Database="ACMEMX02\13th Storage Group\S Mailboxes"}

         "[T]" {$Database="ACMEMX02\14th Storage Group\T Mailboxes"}

         "[U-V]" {$Database="ACMEMX02\15th Storage Group\U-V Mailboxes"}

         "[W-Z]" {$Database="ACMEMX02\16th Storage Group\W-Z Mailboxes"}

         "[H]" {$Database="ACMEMX02\17th Storage Group\H Mailboxes"}

         "[I-K]" {$Database="ACMEMX02\18th Storage Group\I-K Mailboxes"}

         "[L]" {$Database="ACMEMX02\19th Storage Group\L Mailboxes"}

         "[M]" {$Database="ACMEMX02\20th Storage Group\M Mailboxes"}

         "[N-O]" {$Database="ACMEMX02\21st Storage Group\N-O Mailboxes"}

         "[P-Q]" {$Database="ACMEMX02\22nd Storage Group\P-Q Mailboxes"}

         "[C]" {$Database="ACMEMX02\8th Storage Group\C Mailboxes"}

         "[D]" {$Database="ACMEMX02\9th Storage Group\D Mailboxes"}

         "[R]" {$Database="ACMEMX02\23rd Storage Group\R Mailboxes"}
		 
		 "[ads]" 

                        }

       

       new-mailbox -name $DisplayName -alias $alias -Firstname $name -LastName $last -userPrincipalName $userprincipalname `

       -database $Database -OrganizationalUnit $templateDN -Password $Password


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

 

   $groups=get-qaduser $tmplateUser | select -ExpandProperty memberof

   foreach ($Group In $groups)

   {

      add-qadgroupmember -identity $Group -member $user

   }

            $arrAttrs="department"

            $user.pwdLastSet=0

            $user.displayName=$displayName

            $user.SetInfo()


            foreach ($Arr In $arrAttrs)

            {

                        $updatedAttr=$UserToCopy.Get($Arr)

                        $user.Put($Arr,$updatedAttr)

            }

            $user.SetInfo()

            $user.physicalDeliveryOfficeName=$user.department

            $user.description=$user.title

            $user.SetInfo()

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