;--------Name of output exe file----------
outfile 'InstallOLabs2.1.exe'
;-----------------------------------------
Name "OLabs"
;------ Settings of installer Window---------
!define SetTitleBar "OLabs Installer 2.1"
Caption "OLabs Installer 2.1"
!define MUI_ICON "D:\OLabs 2.0\CodeToCompile\Icons\olabs-logo.ico"


BrandingText "Developed by C-DAC, Mumbai"
ShowInstDetails nevershow
AllowRootDirInstall true
!addplugindir "C:\Program Files (x86)\NSIS\Plugins"
XPStyle on
;-----------------------------------------
;-------Product Information----------------
!define PRODUCT_NAME "OLabs"
!define PRODUCT_PUBLISHER "Amrita University & CDAC Mumbai"
!define PRODUCT_WEB_SITE "http://www.olabs.edu.in"
!define SIZE "2000"
!define APPNAME "OLabs"
!define version "2.1"
!define INSTALLSIZE 1536000


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
;!include GetTime.nsh
!insertmacro "VersionCompare"


InstallColors FF8080 000030
;------GUI Pages----------------------------------

!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "Are you sure you want to quit OLabs Setup??"

!define WELCOME_TITLE "Welcome to the OLabs Setup Wizard."
!define UNWELCOME_TITLE "OLabs installation Setup completed"

!define MUI_WELCOMEPAGE_TEXT "Setup will guide you through the installation of OLabs.\n\r \n\rIt is recommended that you close all other applications before starting the Setup.\n\r\n\rClick 'Next' to continue."
!define FINISH_TITLE "OLabs installation setup completed"
!define MUI_FINISHPAGE_TEXT "OLabs has been installed on your computer. Click 'Finish' to close the setup!"


!define MUI_WELCOMEPAGE_TITLE '${WELCOME_TITLE}'
!define MUI_WELCOMEPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_WELCOME

!define MUI_TEXT_LICENSE_SUBTITLE "Please read the License terms before installing OLabs."
!define MUI_LICENSEPAGE_TEXT_TOP "You must accept the agreement to install OLabs."
!define MUI_INNERTEXT_LICENSE_BOTTOM "If you accept the terms of the agreement, click 'I Agree' to continue."
!insertmacro MUI_PAGE_LICENSE "D:\OLabs 2.0\CodeToCompile\Include\License.rtf"
;License.txt

Page custom nsDialogsPage
;-------Custom page variables---------
Var Dialog
Var CustomHeaderText
Var CustomSubText
Var path
Var temp1
Var CONTROL
;-------------------------------------

 Function .onInit
	
	System::Call "kernel32::GetCurrentDirectory(i ${NSIS_MAX_STRLEN}, t .r0)"
	
	SetOutPath $0
	File "D:\OLabs 2.0\CodeToCompile\Include\components.rtf"
	StrCpy $path "$0"
	
 FunctionEnd
 
 Function .onGUIEnd

	Delete "$path\components.rtf"
	
 
 FunctionEnd
;var temp
;------------------------------------------------------------------------------------------------
;------Custom page function----------
Function nsDialogsPage

	StrCpy $CustomHeaderText "Components of OLabs Installer"
	StrCpy $CustomSubText "Detail list of components are"
	!insertmacro MUI_HEADER_TEXT $CustomHeaderText  $CustomSubText 
	!define SF_RTF 2
	!define EM_STREAMIN 1097

	nsDialogs::Create /NOUNLOAD 1018
	Pop $Dialog

	${If} $Dialog == error
		Abort
	${EndIf}

	nsDialogs::CreateControl /NOUNLOAD "RichEdit20A" ${ES_READONLY}|${WS_VISIBLE}|${WS_CHILD}|${WS_TABSTOP}|${WS_VSCROLL}|${ES_MULTILINE}|${ES_WANTRETURN} ${WS_EX_STATICEDGE} 0 10u 100% 110u ''
	Pop $CONTROL

	FileOpen $4 "$path\components.rtf" r
	
	StrCpy $0 $CONTROL

	SendMessage $CONTROL ${EM_EXLIMITTEXT} 0 0x7fffffff
	; set EM_AUTOURLDETECT to detect URL automatically
	SendMessage $CONTROL 1115 1 0

	System::Get /NoUnload "(i, i .R0, i .R1, i .R2) iss"
	Pop $2
	System::Call /NoUnload "*(i 0, i 0, k r2) i .r3"

	System::Call /NoUnload "user32::SendMessage(i r0, i ${EM_STREAMIN}, i ${SF_RTF}, i r3) i.s"

	loop:
		Pop $0
		StrCmp $0 "callback1" 0 done
		System::Call /NoUnload "kernel32::ReadFile(i $4, i $R0, i $R1, i $R2, i 0)"
		Push 0 # callback's return value
		System::Call /NoUnload "$2"
	goto loop
	done:
		System::Free $2
		System::Free $3
		FileClose $4
	GetDlgItem $0 $HWNDPARENT 3
	EnableWindow $0 0
	nsDialogs::Show

FunctionEnd
;--------Custom page function end------------

!define MUI_PAGE_HEADER_TEXT "Choose Install Location."
!define MUI_PAGE_HEADER_SUBTEXT "Choose the folder in which you want to install OLabs"
!insertmacro MUI_PAGE_DIRECTORY 
DirText "Setup will install OLabs in the following folder. To install in a different folder click 'Browse' and select another folder. Click 'Install' to start the installation." "Destination Folder" "" ""


!define MUI_PAGE_HEADER_TEXT "Extracting"
!define MUI_PAGE_HEADER_SUBTEXT "Please wait while OLabs files are being extracted."
!insertmacro MUI_PAGE_INSTFILES

InstallDir "C:\OLabs"
Section "OLabs"
	SectionIn RO
	;Missing MS C++ 2008 runtime library warning here
	ReadRegStr $R2 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}' DisplayVersion
	ReadRegStr $R3 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{350AA351-21FA-3270-8B7A-835434E766AD}' DisplayVersion
	ReadRegStr $R4 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2B547B43-DB50-3139-9EBE-37D419E0F5FA}' DisplayVersion

	ReadRegStr $R5 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{9A25302D-30C0-39D9-BD6F-21E6EC160475}' DisplayVersion
	ReadRegStr $R6 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{8220EEFE-38CD-377E-8595-13398D740ACE}' DisplayVersion
	ReadRegStr $R7 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5827ECE1-AEB0-328E-B813-6FC68622C1F9}' DisplayVersion

	ReadRegStr $R8 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1F1C2DFC-2D24-3E06-BCB8-725134ADF989}' DisplayVersion
	ReadRegStr $R9 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4B6C7001-C7D6-3710-913E-5BC23FCE91E6}' DisplayVersion
	ReadRegStr $R0 HKLM 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{977AD349-C2A8-39DD-9273-285C08987C7B}' DisplayVersion

	StrCmp $R2 "" vc9_test2
	GOTO vcDone
	vc9_test2:
	StrCmp $R3 "" vc9_test3
	GOTO vcDone
	vc9_test3:
	StrCmp $R4 "" vc9_test4
	GOTO vcDone
	vc9_test4:
	StrCmp $R5 "" vc9_test5
	GOTO vcDone
	vc9_test5:
	StrCmp $R6 "" vc9_test6
	GOTO vcDone
	vc9_test6:
	StrCmp $R7 "" vc9_test7
	GOTO vcDone
	vc9_test7:
	StrCmp $R8 "" vc9_test8
	GOTO vcDone
	vc9_test8:
	StrCmp $R9 "" vc9_test9
	GOTO vcDone
	vc9_test9:
	StrCmp $R0 "" no_vc9
	GOTO vcDone

	;If C++ library is not already installed then installing C++ library
	no_vc9:
		SetOutPath '$INSTDIR'
		File "D:\OLabs 2.0\CodeToCompile\Include\vcredist_x86.exe"
		ExecWait '"$INSTDIR\vcredist_x86.exe"' $0
		StrCmp $0 "0" vcDone
		MessageBox MB_OK "Installation failed (vcredist_x86.exe)"
		goto end
	
	;Main OLabs installation			
	vcDone:	
		SetOutPath '$INSTDIR'
		;----------------Extract OLabs Files------------------------------------
		StrCpy $0 1
		InitPluginsDir
		SetDetailsPrint textonly
		CreateDirectory "$INSTDIR\temp"
		;------Image Files for installer slide show--------------- 
		SetOutPath "$INSTDIR\temp"
		File "D:\OLabs 2.0\CodeToCompile\Slides\1.jpg"
		File "D:\OLabs 2.0\CodeToCompile\Slides\2.jpg"
		File "D:\OLabs 2.0\CodeToCompile\Slides\3.jpg"
		File "D:\OLabs 2.0\CodeToCompile\Slides\4.jpg"
		File "D:\OLabs 2.0\CodeToCompile\Slides\5.jpg"
		File "D:\OLabs 2.0\CodeToCompile\Slides\6.jpg"
		File "D:\OLabs 2.0\CodeToCompile\Slides\7.jpg"
		File "D:\OLabs 2.0\CodeToCompile\Slides\8.jpg"
		File "D:\OLabs 2.0\CodeToCompile\Slides\Slides.dat"
		nsisSlideshow::show /NOUNLOAD "/auto=$INSTDIR\temp\Slides.dat"
		;-----------------------------------------------------------
		;Adding OLabs folder in installer
		
		SetOutPath '$INSTDIR'
		File /r "OLabs\*"
		
		;-----------------------------------------------------------------------
	
		;-----------Create Shortcuts--------------------------------------------
		SetOutPath "$INSTDIR"
		CreateShortCut "$DESKTOP\OLabs_Startup.lnk" "$INSTDIR\OLabs_Startup.exe"
		CreateShortCut "$DESKTOP\OLabs_Stop.lnk" "$INSTDIR\OLabs_Stop.exe"
		Sleep 3000
		;------------------------------------------------------------------------
		# Start Menu
		createDirectory "$SMPROGRAMS\OLabs"
		createShortCut "$SMPROGRAMS\OLabs\OLabs_Startup.lnk" "$INSTDIR\OLabs_Startup.exe"
		createShortCut "$SMPROGRAMS\OLabs\OLabs_Stop.lnk" "$INSTDIR\OLabs_Stop.exe"
		createShortCut "$SMPROGRAMS\OLabs\uninstall.lnk" "$INSTDIR\uninstall.exe"  
		;commented cause it will be added in next version
		createShortCut "$SMPROGRAMS\OLabs\Check for Update.lnk" "$INSTDIR\Check for Update.exe"
		;Writing setenv.bet file to link jre with tomcat as per user's OLabs installation directory
		FileOpen $9 $INSTDIR\tomcat\bin\setenv.bat w 
		FileWrite $9 'set "JRE_HOME=$INSTDIR\jre\"$\r$\n'
		FileWrite $9 "exit /b 0"
		FileClose $9 


		;---------Update XAMPP configuration paths-----------------------
		SetOutPath "$INSTDIR"
		DetailPrint "Updating OLabs configuration files...Please Wait.."
		
		;Refreshing XAMPP files to update path
		ExecWait '"$INSTDIR\php\php.exe" -n -d output_buffering=0 "$INSTDIR\install\install.php" usb' $0
		StrCmp $0 "0" php_done
		MessageBox MB_OK "Installation failed (php.exe)"
		goto clean
		
		php_done:
			# Registry information for add/remove programs
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OLabs" "DisplayName" "OLabs"
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OLabs" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OLabs" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OLabs" "InstallLocation" "$\"$INSTDIR$\""
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OLabs" "DisplayIcon" "$\"$INSTDIR\logo.ico$\""
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OLabs" "Publisher" "Centre For Development For Advanced Computing"
			WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OLabs" "DisplayVersion" "2.1"
			# There is no option for modifying or repairing the install
			WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OLabs" "NoModify" 1
			WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OLabs" "NoRepair" 1
			# Set the INSTALLSIZE constant (!defined at the top of this script) so Add/Remove Programs can accurately report the size
			WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OLabs" "EstimatedSize" ${INSTALLSIZE}
		
	
			; L for local time, $0-day $1-month $2-year $3-day of week $4-hour $5-minute $6-seconds
			${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
			StrCpy $temp1 $3
			WriteRegStr HKLM SOFTWARE\OLabs "Install_Dir" "$INSTDIR"
			WriteRegStr HKLM SOFTWARE\OLabs "Version" "2.1"
			WriteRegStr HKLM SOFTWARE\OLabs "day" "$temp1"
		
			SetDetailsView show
			goto DeleteFiles
		;------------------------------------------------------------------
						
		end:	
			MessageBox MB_OK "OLabs extraction failed..Please start the setup again"	
			goto clean
									
;------Delete extracted files--------------  
						
DeleteFiles:						
	Delete '$INSTDIR\vcredist_x86.exe'	
	RMDir /r "$INSTDIR\temp" 
	Delete "$path\components.rtf"
	goto success
;------------------------------------------	
clean:
	RMDir /r "$INSTDIR" 
	Delete "$DESKTOP\OLabs_Startup.lnk"
	Delete "$DESKTOP\OLabs_Stop.lnk"
	Delete "$SMPROGRAMS\OLabs\OLabs_Startup.lnk"
	Delete "$SMPROGRAMS\OLabs\OLabs_Stop.lnk"
	Delete "$SMPROGRAMS\OLabs\uninstall.lnk"
	Delete "$SMPROGRAMS\OLabs\Check for Update.lnk"
	RMDir "$SMPROGRAMS\OLabs"
success:
	
SectionEnd

;---------Finish page setting--------------
!define MUI_FINISHPAGE_TITLE '${FINISH_TITLE}'
!define MUI_FINISHPAGE_TITLE_3LINES
!define MUI_FINISHPAGE_RUN "$INSTDIR\OLabs_Startup.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch OLabs Now"
!insertmacro MUI_PAGE_FINISH
Name "OLabs"

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

;-----------------------------------------------
;-------Un-installer Sections------------
Section -
	SetOutPath '$INSTDIR'
	WriteUninstaller 'uninstall.exe'
SectionEnd
Function un.onInit
	
	#Verify the uninstaller - last chance to back out
	MessageBox MB_OKCANCEL "Are you sure you want to remove OLabs completely?" IDOK next
		Abort
	next:
	
FunctionEnd
Section Uninstall
	;SetShellVarContext all
	ReadRegStr $INSTDIR HKLM "SOFTWARE\OLabs" "Install_Dir"
	DetailPrint "Stopping servers..."
	ExecWait "$INSTDIR\mycatalina_stop.bat"
	ExecWait "$INSTDIR\apache_stop.bat"
	ExecWait "$INSTDIR\mysql_stop.bat"
	ExecWait "$INSTDIR\KillAll.bat"

	
	Delete "$INSTDIR\uninstall.exe"
	RMDir /r "$INSTDIR\*.*" 
	
	RMDir "$INSTDIR"
	Delete "$DESKTOP\OLabs_Startup.lnk"
	Delete "$DESKTOP\OLabs_Stop.lnk"
	SetShellVarContext all
	Delete "$SMPROGRAMS\OLabs\OLabs_Startup.lnk"
	Delete "$SMPROGRAMS\OLabs\OLabs_Stop.lnk"
	Delete "$SMPROGRAMS\OLabs\uninstall.lnk"
	Delete "$SMPROGRAMS\OLabs\Check for Update.lnk"
	RMDir "$SMPROGRAMS\OLabs"

	DeleteRegKey HKLM "SOFTWARE\OLabs"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OLabs"
	;MessageBox MB_OK "You have successfully uninstalled OLabs."
SectionEnd
Function un.onGUIEnd
	Delete "$DESKTOP\OLabs_Startup.lnk"
	Delete "$DESKTOP\OLabs_Stop.lnk"
FunctionEnd
;------------------------------------------