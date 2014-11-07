
Import-Module ActiveDirectory

$name = read-host -prompt "First Name?"
      
$lastname = read-host -prompt "Last Name?"

$Phone = read-host -prompt "Phone Number?"

$Password = read-host -prompt "Password?" -AsSecureString
	  
$DisplayName = "$Name $lastname"
	  
$FirstNameInit=$name

$FirstNameInit=$FirstNameInit.substring(0,1)
	  
$alias="$firstnameinit$lastname"
	  
$user=$alias
	  
$DeptNumber = read-host -prompt "Client Code?"

      switch -regex ($DeptNumber)
	  {
		"[p2p]" {$clienturl="power2practice.com"}
		"[dgr]" {$clienturl="dgrlegal.com"}
		"[acb]" {$clienturl="acbanet.org"}
		"[pfs]" {$clienturl="pfs-llc.net"}
		"[sfc]" {$clienturl="sfcasa.org"}
		"[hsc]" {$clienturl="hearingspeech.org"}
		"[toe]" {$clienturl="toeroek.com"}
		"[abs]" {$clienturl="absnorthbay.com"}
        "[sym]" {$clienturl="symbiosystems.com"}
        "[dnc]" {$clienturl="cunningham-md.com"}
		"[mlg]" {$clienturl="mitchelllawsf.com"}
				}

$userprincipalname="$alias@$clienturl"


#Getting the Parent OU to pass to new-mailbox
$suffix="TEMPLATE"

$tmplateUser=read-host -prompt "User to copy groups from?"

$tmp = Get-ADUser -Identity $tmplateUser
$DN = $tmp.distinguishedName
$tmpUser = [ADSI]"LDAP://$DN"
$Parent = $tmpUser.Parent



                             

       new-mailbox -name $DisplayName -alias $alias -Firstname $name -LastName $lastname -userPrincipalName $userprincipalname -OrganizationalUnit $Parent -Password $Password


#The following is used to create the home folder:

$pathToShare="\\$clienturl\home\$user"

New-Item -type directory -path $pathToShare|Out-Null


#Get groups from $tmplateUser (specified in write-host) and add groups to new user

Get-ADUser -Identity $tmplateUser -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $alias


#Now we need to set the appropriate permission for the home folder.

function SetSharePerm

    {

     Param([string]$user)

     $shareName="\\$clienturl\home\$user"

     $userName="$clienturl\$user"

     $SUBINACL='c:\subinacl.exe'

     &$SUBINACL /grant=$userName=C |Out-Null

        }

write-host $name
write-host $user
write-host $clienturl
write-host $DeptNumber
write-host $pathtoshare

#Finally, we will send an email to the Help Desk to notify them that the accounts have been created.
#not required at the moment
#function mailit {
#
#Param(
#
#[string]$user,
#
#[string]$FirstName,
#
#[string]$LastName
#
#)
#
#$EmailList="helpdesk@acme.org"
#
#$MailMessage= @{
#
#To=$EmailList
#
#From="DONOTREPLY@acme.org"
#
#Subject="NEW USER ACCorganizational unitNT"
#
#Body="A new user account has been created. Initial login information listed below: `n
#
#First name: $FirstName
#
#Last name:  $LastName
#
#Userid: $user
#
#Password: letmein
#
#Thank You."
#
#SmtpServer="smtp.acme.org"
#
#ErrorAction="Stop"
#
#            }
#
#Send-MailMessage @MailMessage
#
#}