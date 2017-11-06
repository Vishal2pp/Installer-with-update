;--------Name of output exe file----------
outfile "Check for update.exe"
;-----------------------------------------
;------ Settings of installer Window---------
!define SetTitleBar "OLabs Updater"
Caption "OLabs Updater"
!define MUI_ICON "D:\OLabs 2.0\CodeToCompile\Icons\update1.ico"
BrandingText "Developed by C-DAC, Mumbai"
;ShowInstDetails nevershow
AllowRootDirInstall true
!addplugindir "C:\Program Files (x86)\NSIS\Plugins"
XPStyle on
;-----------------------------------------
;-------Product Information----------------
!define PRODUCT_NAME "OLabs"
!define PRODUCT_PUBLISHER "Amrita University & CDAC Mumbai"
!define PRODUCT_WEB_SITE "http://www.olabs.edu.in"
!define SIZE "2000"
!define APPNAME "OLabs Updater"
;-------------------------------------------
;-------Header Files-----------------------
!include MUI.nsh
!include MUI2.nsh
!include nsDialogs.nsh
!include wordfunc.nsh
!include X64.nsh
!include logiclib.nsh
!include WinMessages.nsh
!include FileFunc.nsh
!include VersionCheckV5.nsh
!include StrFunc.nsh

${StrTrimNewLines}

InstallColors FF8080 000030
;------GUI Pages----------------------------------

!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "Are you sure you want to quit OLabs Updater??"

!define WELCOME_TITLE "Welcome to the OLabs update Wizard."
!define UNWELCOME_TITLE "Updating OLabs completed."

!define MUI_WELCOMEPAGE_TEXT "Setup will guide you through the installation of OLabs updates.\n\r \n\rIt is recommended that you close all other applications before starting the updates.\n\r\n\rClick 'Next' to continue."
!define FINISH_TITLE "Updating OLabs completed"
!define MUI_FINISHPAGE_TEXT "Latest OLabs updates are installed on your computer. Click 'Finish' to close the window!"


!define MUI_WELCOMEPAGE_TITLE '${WELCOME_TITLE}'
!define MUI_WELCOMEPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_WELCOME

Page custom nsDialogsPage MyPageLeave
;-------Custom page variables---------
Var CustomHeaderText
Var CustomSubText
;-------------------------------------
;User variables
var url
var OldVersion
var server_md5
var local_md5
var newVersion
var req_size
var ava_size
var string
var flag
var dialog
var hwnd 
;-------------------Function to get free space--------------------------------
!define sysGetDiskFreeSpaceEx 'kernel32::GetDiskFreeSpaceExA(t, *l, *l, *l) i'
Function FreeDiskSpace
  System::Call '${sysGetDiskFreeSpaceEx}(r0,.,,.r1)'
  System::Int64Op $1 / 1000000
  Pop $1
FunctionEnd

;------------------------------------------------------------------------------------------------
;------Custom page function----------
Function nsDialogsPage
	ReadRegStr $INSTDIR HKLM "SOFTWARE\OLabs" "Install_Dir"
	;Checking Internet connection
	DetailPrint "Checking internet connection..."
	Dialer::GetConnectedState
	Pop $1
	StrCmp $1 "online" checkUpdate
	MessageBox MB_OK "Internet connection is not available. Make sure you have working internet connection and try again."
	Quit
	
	
	;Downloading version file from server
	checkUpdate:
			;SetDetailsPrint none
			;DetailPrint "Checking for updates please wait...."
			;passing directory to get available free space
			StrCpy $0 "$INSTDIR"
			Call FreeDiskSpace
			StrCpy $ava_size $1
			CreateDirectory "$INSTDIR\temp"
		
			NSISdl::download_quiet "http://10.212.8.230:8080/version.txt" "$INSTDIR\temp\temp.txt"
			Pop $R0
			StrCmp $R0 "success" compare
			MessageBox MB_RETRYCANCEL "Failed to download Version file. $R0. Please try again." IDRETRY checkUpdate IDCANCEL abort
			FileClose $0
			RMDir /r "$INSTDIR\temp"
			Quit
			abort:
				Quit
	;Reading version file
	compare:
		;DetailPrint "Comparing version..."
		FileOpen $0 "$INSTDIR\temp\temp.txt" r
		FileRead $0 $1
		StrCpy $newVersion $1
		FileRead $0 $1
		StrCpy $req_size $1
		FileRead $0 $1
		${StrTrimNewLines} $url $1
		FileRead $0 $1
		${StrTrimNewLines} $server_md5 $1
		;Reading installed version from user's registry
		ReadRegStr $OldVersion HKLM "SOFTWARE\OLabs" "Version"
		
		;Comparing versions
		${VersionCheckNew} "$OldVersion" "$newVersion" "$R0"
		${If} $R0 == 2
			NSISdl::download_quiet "http://10.212.8.230:8080/releasenote.txt" "$INSTDIR\temp\releasenote.txt"
			Pop $R0
			StrCmp $R0 "success" ok
			;MessageBox MB_OK "Could not connect the server: $R0. Please try again later."
			MessageBox MB_RETRYCANCEL "Could not connect to the server. $R0. Please try again later." IDRETRY compare IDCANCEL abort
			FileClose $0
			RMDir /r "$INSTDIR\temp"
			Quit
		${Else}
			;MessageBox MB_OK "Latest update of OLabs has already been installed on your computer."
			FileClose $0
			RMDir /r "$INSTDIR\temp"
			Goto test
			;Quit
		${EndIf}
	ok:
		StrCpy $CustomHeaderText "What's new in OLabs"
		StrCpy $CustomSubText "Details of OLabs updates"
		!insertmacro MUI_HEADER_TEXT $CustomHeaderText  $CustomSubText 
		!define SF_RTF 2
		!define EM_STREAMIN 1097
		StrCpy $flag "0"
		nsDialogs::Create 1018
		Pop $0

		nsDialogs::CreateControl /NOUNLOAD ${__NSD_Text_CLASS} ${DEFAULT_STYLES}|${WS_TABSTOP}|${ES_AUTOHSCROLL}|${ES_MULTILINE}|${WS_VSCROLL}|${WS_HSCROLL} ${__NSD_Text_EXSTYLE} 0 10u 100% 110u ''
		Pop $1

		CustomLicense::LoadFile "$INSTDIR\temp\releasenote.txt" $1
		;GetDlgItem $0 $HWNDPARENT 3
		;EnableWindow $0 0
		nsDialogs::Show
		Goto end
		test:
		Call test
		end:
FunctionEnd
;--------Custom page function end------------

Function test
	StrCpy $CustomHeaderText "OLabs is upto date"
	StrCpy $CustomSubText "Details of OLabs updates"
	!insertmacro MUI_HEADER_TEXT $CustomHeaderText  $CustomSubText 
	;!define SF_RTF 2
	;!define EM_STREAMIN 1097
	nsDialogs::Create 1018
    Pop $dialog
 
    ${NSD_CreateLabel} 0 0 100% 20% "Latest updates of OLabs has already been installed on your computer.$\nClick 'Finish' to close the wizard."
    Pop $hwnd
    ;${NSD_AddStyle} $hwnd ${SS_CENTER}
	GetDlgItem $0 $hwndparent 1 ; Get the handle to the button
	SendMessage $0 ${WM_SETTEXT} 0 `STR:Finish` 
	StrCpy $flag "1"
	nsDialogs::Show

FunctionEnd

Function MyPageLeave
;MessageBox MB_OK $flag
StrCmp $flag "0" pass
Quit
pass:
FunctionEnd


!define MUI_PAGE_HEADER_TEXT "Updating"
!define MUI_PAGE_HEADER_SUBTEXT "Please wait while OLabs is being updated."
!insertmacro MUI_PAGE_INSTFILES


Section "OLabs"
	DetailPrint "Stopping servers..."
	execWait "mycatalina_stop.bat"
	execWait "apache_stop.bat"
	execWait "mysql_stop.bat"
	execWait "KillAll.bat"
	
	${If} $req_size < $ava_size
		goto fetch
	${Else}
		;Taking first 3 letters only into $string to print drive name
		StrCpy $string $INSTDIR 3
		MessageBox MB_OK "Not enough disk space available in $string drive. Update requires minimum $req_size MB space. Free some space and try again."
		;FileClose $0
		RMDir /r "$INSTDIR\temp"
		goto Finish
	${EndIf}
	
	;fetching updates from repository 
	fetch:
		DetailPrint "Downloading update package. Please wait till download gets completed..."
		;SetDetailsPrint none
		;ShowInstDetails none 
		FindWindow $0 "#32770" "" $HWNDPARENT
		GetDlgItem $1 $0 0x3ec
		ShowWindow $1 ${SW_HIDE}
		NSISdl::download "$url" "$INSTDIR\temp\update.exe"
		Pop $R0
		StrCmp $R0 "success" ExtractFiles
		SetDetailsPrint both
		DetailPrint "Update downloading failed"
		MessageBox MB_RETRYCANCEL "Update downloading failed. $R0." IDRETRY fetch IDCANCEL Finish
		RMDir /r "$INSTDIR\temp"
		goto Finish
	
	ExtractFiles:
		;Calculating MD5 sum of downloaded file
		md5dll::GetMD5File "$INSTDIR\temp\update.exe"
		Pop $0
		StrCpy $local_md5 $0
		;Comparing calculated MD5 with MD5 from the version file
		StrCmp $server_md5 $local_md5 same notsame
		same:
			DetailPrint "Copying new files..."
			CreateDirectory "$INSTDIR\htdocs1"
			;Executing update.exe
			;SetDetailsPrint none
			HideWindow
			ExecWait "$INSTDIR\temp\update.exe" $0
			BringToFront
			StrCmp $0 "0" InstallFiles
			MessageBox MB_OK "Update extraction failed. Please try again later."
			RMDir /r "$INSTDIR\htdocs1"
			RMDir /r "$INSTDIR\temp"
			goto Finish
		notsame:
			MessageBox MB_OK "Downloaded files are corrupted or invalid. Please try again. "
			RMDir /r "$INSTDIR\temp"
			goto Finish
		
	
	InstallFiles:
		;Removing Old files after updating new files
		DetailPrint "Deleting old files..."
		RMDir /r "$INSTDIR\htdocs"
		RMDir /r "$INSTDIR\temp"
		Rename "$INSTDIR\htdocs1\" "$INSTDIR\htdocs\"
		;Adding new version number into registry
		WriteRegStr HKLM SOFTWARE\OLabs "Version" "$newVersion"
		DetailPrint "OLabs update completed"
		MessageBox MB_OK "OLabs update completed."
		SetAutoClose true
	Finish:
		RMDir /r "$INSTDIR\temp"
		Quit

SectionEnd

;---------Finish page setting--------------
!define MUI_FINISHPAGE_TITLE '${FINISH_TITLE}'
!define MUI_FINISHPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_FINISH


!define MUI_WELCOMEPAGE_TITLE "Welcome to OLabs Uninstaller wizard."
!define MUI_WELCOMEPAGE_TEXT "Setup will guide you through the uninstallation of OLabs.\n\r \n\rBefore starting the uninstallation, make sure OLabs is not running.\n\r \n\rClick 'Next' to continue."
!insertmacro MUI_UNPAGE_WELCOME
!define MUI_PAGE_HEADER_TEXT "Uninstall OLabs"
!define MUI_PAGE_HEADER_SUBTEXT "Remove OLabs from your computer."
!define MUI_UNCONFIRMPAGE_TEXT_TOP "OLabs will be uninstalled from the following folder. Click 'Uninstall' to start the uninstallation."
!define MUI_UNCONFIRMPAGE_TEXT_LOCATION "Uninstalling from:"
!insertmacro MUI_UNPAGE_CONFIRM
!define MUI_PAGE_HEADER_TEXT "Uninstall OLabs"
!define MUI_PAGE_HEADER_SUBTEXT "Removing OLabs from your computer"
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "Uninstall completed."
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "OLabs is removed from your computer."
!insertmacro MUI_UNPAGE_INSTFILES
!define MUI_FINISHPAGE_TITLE "OLabs uninstallation setup completed."
!define MUI_FINISHPAGE_TEXT "OLabs has been uninstalled from your computer.Click 'Finish' to close the setup!"
!insertmacro MUI_UNPAGE_FINISH



!insertmacro MUI_LANGUAGE "English"

