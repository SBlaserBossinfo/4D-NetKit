//%attributes = {"invisible":true}
C_TEXT($1; $2; $3; $4; $5; $6)

var $redirectURI : Text
var $responseFile; $customResponseFile; $customErrorFile : 4D.File

$responseFile:=Folder(fk resources folder).file("Response_Template.html")

If (OB Is defined(Storage; "params"))
	Use (Storage.params)
		$redirectURI:=String(Storage.params.redirectURI)
		If (Length($redirectURI)>0)
			$redirectURI:=_getPathFromURL($redirectURI)+"@"
		End if 
		$customResponseFile:=(Value type(Storage.params.authenticationPage)#Is undefined) ? Storage.params.authenticationPage : Null
		$customErrorFile:=(Value type(Storage.params.authenticationErrorPage)#Is undefined) ? Storage.params.authenticationErrorPage : Null
	End use 
End if 

If ($1=$redirectURI)
	
	var $result : Object
	var WSTITLE; WSMESSAGE; WSDETAILS : Text
	
	ARRAY TEXT($names; 0)
	ARRAY TEXT($values; 0)
	WEB GET VARIABLES($names; $values)
	
	If (Size of array($names)>0)
		
		var $i : Integer
		$result:=New shared object
		Use ($result)
			For ($i; 1; Size of array($names))
				$result[$names{$i}]:=$values{$i}
			End for 
		End use 
		
	End if 
	
	Use (Storage)
		Storage.token:=$result
	End use 
	
	If (($result=Null) | (OB Is defined($result; "error")))
		
		WSTITLE:=Get localized string("OAuth2_Response_Title")
		WSMESSAGE:=Get localized string("OAuth2_Error_Message")
		
		If (OB Is defined($result; "error"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error
		End if 
		If (OB Is defined($result; "error_subtype"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error_subtype
		End if 
		If (OB Is defined($result; "error_description"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error_description
		End if 
		If (OB Is defined($result; "error_uri"))
			WSMESSAGE:=WSMESSAGE+"<br /><br />"+$result.error_uri
		End if 
		WSDETAILS:=Get localized string("OAuth2_Response_Details")
		
		$responseFile:=($customErrorFile#Null) ? $customErrorFile : $responseFile
	Else 
		
		WSTITLE:=Get localized string("OAuth2_Response_Title")
		WSMESSAGE:=Get localized string("OAuth2_Response_Message")
		WSDETAILS:=Get localized string("OAuth2_Response_Details")
		
		$responseFile:=($customResponseFile#Null) ? $customResponseFile : $responseFile
	End if 
	
	WEB SEND FILE($responseFile.platformPath)
	
Else 
	
	// Nothing to do... 404 will be automatically sent
	
End if 