OutFile "OLabs_Startup.exe"

;Header files
!include MUI.nsh
!include MUI2.nsh
!include ports.nsh
!include logiclib.nsh
!include VersionCheckV5.nsh
!include StrFunc.nsh
!include GetTime.nsh

BrandingText "Developed by C-DAC, Mumbai"
;Icon file
!define MUI_ICON "D:\OLabs 2.0\CodeToCompile\Icons\start.ico"
!define SetTitleBar "OLabs 2.1 Startup"
Caption "OLabs 2.1 Startup"
!define MUI_PAGE_HEADER_TEXT "Starting OLabs"
!define MUI_PAGE_HEADER_SUBTEXT "Please wait while Servers are being started."
!insertmacro MUI_PAGE_INSTFILES
RequestExecutionLevel admin
!addplugindir "C:\Program Files (x86)\NSIS\Plugins"

;User variables
var url
var OldVersion
var server_md5
var local_md5
var newVersion
var portno
var req_size
var ava_size
var string 
var date
var temp1

;-----------------------------------------------------------------------------
;----Function to write httpd.conf file----------------------------------------
Function WriteToFileLine2
	Exch $0 ;file
	Exch
	Exch $1 ;line number
	Exch 2
	Exch $2 ;string to write
	Exch 2
	Push $3
	Push $4
	Push $5
	Push $6
	Push $7
	 
	 GetTempFileName $7
	 FileOpen $4 $0 r
	 FileOpen $5 $7 w
	 StrCpy $3 0
	 
	Loop:
		ClearErrors
		FileRead $4 $6
		IfErrors Exit
		 IntOp $3 $3 + 1
		 StrCmp $3 $1 0 +3
		FileWrite $5 "$2$\r$\n"
		Goto Loop
		FileWrite $5 $6
		Goto Loop
	Exit:
	 
	 FileClose $5
	 FileClose $4
	 
	SetDetailsPrint none
	Delete $0
	Rename $7 $0
	SetDetailsPrint both
	 
	Pop $7
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd
;-----------------------------------------------------------------------------

Section
	;Reading installation path from the registry
	ReadRegStr $INSTDIR HKLM "SOFTWARE\OLabs" "Install_Dir"
	DetailPrint "Stopping servers..."
	execWait "mycatalina_stop.bat"
	execWait "apache_stop.bat"
	execWait "mysql_stop.bat"
	execWait "KillAll.bat"
	
	;Checking Internet connection
	DetailPrint "Checking internet connection..."
	Dialer::GetConnectedState
	Pop $1
	StrCmp $1 "online" checkDate
	goto PortCheck
	
	;checking last server hit date. We allow user to hit the server to check update only once in a day
	checkDate:
		ReadRegStr $date HKLM "SOFTWARE\OLabs" "day"
		; L for local time, $0-day $1-month $2-year $3-day of week $4-hour $5-minute $6-seconds
		${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
		StrCpy $temp1 $3
		${If} $temp1 == $date
			goto PortCheck
		${Else}
			;writing new server hit day into registry 
			WriteRegStr HKLM SOFTWARE\OLabs "day" "$temp1"
			goto checkUpdate
		${EndIf}
	
	
	
	;Downloading version file from server
	checkUpdate:
			DetailPrint "Checking for updates please wait...."
			;passing directory to get available free space
			StrCpy $0 "$INSTDIR"
			CreateDirectory "$INSTDIR\temp"
			NSISdl::download_quiet "http://10.212.8.230:8080/version.txt" "$INSTDIR\temp\temp.txt"
			Pop $R0
			StrCmp $R0 "success" compare
			;MessageBox MB_RETRYCANCEL "Version file Download failed: $R0. Please try again." IDRETRY checkUpdate IDCANCEL PortCheck
			RMDir /r "$INSTDIR\temp"
			goto PortCheck
	;Reading version file
	compare:
		DetailPrint "Comparing version..."
		FileOpen $0 "$INSTDIR\temp\temp.txt" r
		FileRead $0 $1
		StrCpy $newVersion $1
		FileClose $0
		
		;Reading installed version from user's registry
		ReadRegStr $OldVersion HKLM "SOFTWARE\OLabs" "Version"
		
		;Comparing versions
		${VersionCheckNew} "$OldVersion" "$newVersion" "$R0"
		${If} $R0 == 2
			MessageBox MB_YESNO "New version of OLabs is available. Do you want to update?" IDYES yes IDNO closeResources
			yes:
				HideWindow
				ExecWait "$INSTDIR\Check for update.exe"
				BringToFront
				StrCmp $0 "0" closeResources
		${Else}
			;FileClose $0
			RMDir /r "$INSTDIR\temp"
			goto PortCheck
		${EndIf}
	
	closeResources:
		FileClose $0
		RMDir /r "$INSTDIR\temp"
		goto PortCheck
	
;Checking for free available port	
	PortCheck:
		DetailPrint "Checking for free port..."
		StrCpy $portno 80
		${While} 1 > 0
			  TCP::CheckPort $portno
			  Pop $0
			  StrCmp $0 "free" port_ok
			  IntOp $portno  $portno + 1
		${EndWhile} 
	
	port_ok:
		;Writing new port into httpd.conf file
		Push "Listen $portno"
		Push 47
		Push "$INSTDIR\apache\conf\httpd.conf"
		Call WriteToFileLine2
		;Writing OpenBrowser.bat file with new port selected.
		FileOpen $9 "$INSTDIR\OpenBrowser.bat" w 
		FileWrite $9 "start http://localhost:$portno/www.olabs.edu.in/"
		FileClose $9 
		;Starting servers
		DetailPrint "Starting servers..."
		Sleep 3000
		execWait "min_apache.bat"
		
		Sleep 1000 
		exec "min_sql.bat"
		
		Sleep 1000
		execWait "min_tomcat.bat"
		
		;Opening browser
		Sleep 5000
		Exec "OpenBrowser.bat"
		SetAutoClose true

SectionEnd
