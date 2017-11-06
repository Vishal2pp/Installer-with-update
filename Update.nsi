OutFile "update.exe"
!include MUI.nsh
!include MUI2.nsh
!include logiclib.nsh

BrandingText "Developed by C-DAC, Mumbai"
!define SetTitleBar "OLabs Updater"
Caption "OLabs Updater"
!define MUI_ICON "D:\OLabs 2.0\CodeToCompile\Icons\update1.ico"
!define MUI_ABORTWARNING
!define MUI_ABORTWARNING_TEXT "Are you sure you want to quit OLabs Updater??"
!define MUI_PAGE_HEADER_TEXT "Updating OLabs"
!define MUI_PAGE_HEADER_SUBTEXT "Please wait while OLabs is being updated."
!insertmacro MUI_PAGE_INSTFILES
RequestExecutionLevel admin

AllowRootDirInstall true
!addplugindir "C:\Program Files (x86)\NSIS\Plugins"
XPStyle on
var isDump
var isWars
Section

	;Set yes or no flag for dump and war files below.
	StrCpy $isDump "yes"
	StrCpy $isWars "no"
	ReadRegStr $INSTDIR HKLM "SOFTWARE\OLabs" "Install_Dir"
	StrCmp $INSTDIR " " start
	MessageBox MB_OK "OLabs installation not found on your computer. Make sure you have OLabs installed on your computer before proceeding."
	Quit
	;if you want to give update of dump. Mention the folder name to be included in updater
	;for example here new updated dump is present in "clean dump" folder. So here File /r "clean dump\*" is written
	;Command is File /r folder_name\*" 
	start: 
	;If you dont want to give update of dump then comment the following 4 lines of code
	${If} $isDump == "yes"
		;MessageBox MB_OK "In dump"
		SetOutPath "$INSTDIR\htdocs1"
		File /r "clean dump\*"
	${EndIf}
	
	
	; If you want to send update of WAR files also then mention the war folder like above.
	;If you dont want to give update of war files then comment the following 4 lines.
	${If} $isWars == "yes"
		;MessageBox MB_OK "In wars"
		SetOutPath "$INSTDIR\tomcat\webapps\"
		;File /r "wars\*"
	${EndIf}
	;to change version file, change log,start and stop exe
	SetOutPath $INSTDIR
	File /r "update\*"
	SetAutoClose true
SectionEnd