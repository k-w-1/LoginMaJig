#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon\loginmajig_all2.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Fileversion=2.0.0.5
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <__ArrayConcatenate.au3>
#Include <GuiComboBox.au3>
#include <Misc.au3>

#include <GuiButton.au3>
#include <GuiMenu.au3>

#include <ImgSearch/ImgSearch.au3>
#include <../Autoit/includes/_hotkeyFuncs.au3>

; ================= Constants, etc ===================

Const $lmj_version="2.0 BETA - NOCFTW4EVR"

;Constants (all in msec)
Global $settings_keyspeed = 60 ;SetKeySpeed() is called after the gui is setup since it reads direct from the control

;default hotkey values, used to keep track of changes later
Global $settings_hotkey_dup = "+!s"
Global $settings_hotkey_up = "+!d"
Global $settings_hotkey_p = "+!a"

#cs
;Future use stuff...
Const $mstsc_cert_warn_text = "This remote connection could harm your local or remote computer. Do not connect unless you know where this connection came from or have used it before."
Const $mstsc_window_hunt_text = "v-exchange-gradeatechs-mss - 127.0.0.1:9100 - Remote Desktop Connection"

const $server_2003_logon_bg_color = "0x185D7B"
const $server_2012_logon_bg_color = "0x001940"
#ce

Global Enum $SEND_DOMAIN_USER_PASS=1000, $SEND_USER_PASS, $SEND_PASS_ONLY

Global $TitleGrabber_last = ""
Global $TitleGrabber_prev_window = ""

Global $login_creds[1][3]

$login_creds[0][0]=' '
$login_creds[0][1]='1'
$login_creds[0][2]=''
$new_creds=$login_creds

; ================= MAIN GUI ===================
$gui_main = GUICreate("Loginmajig v" & $lmj_version, 371, 201, 251, 142, $GUI_SS_DEFAULT_GUI)
$Label1 = GUICtrlCreateLabel("Username:", 16, 20, 55, 17, $SS_RIGHT)
$ctl_username = GUICtrlCreateCombo("domain\user (opt)", 76, 16, 220, 25)
GUICtrlSetTip(-1, "If left blank, LMJ will skip sending the username")
$cSendUsername = GUICtrlCreateCheckbox("Send", 304, 18, 49, 17)
GUICtrlSetState( -1, $GUI_CHECKED )
$Label2 = GUICtrlCreateLabel("Password:", 16, 52, 55, 17, $SS_RIGHT)
$ctl_password = GUICtrlCreateInput("", 76, 48, 220, 21, BitOR($ES_PASSWORD, $ES_AUTOHSCROLL))
$cMaskPassword = GUICtrlCreateCheckbox("Mask", 304, 50, 49, 17)
$Label3 = GUICtrlCreateLabel("Target:", 16, 92, 55, 17, $SS_RIGHT)
;$ctl_sendto = GUICtrlCreateCombo(" to last window (use Alt/Tab to set)", 76, 88, 220, 25, $CBS_DROPDOWNLIST)
$ctl_sendto = GUICtrlCreateInput(" - - -", 76, 88, 220, 21, $ES_READONLY)
;GUICtrlSetData(-1, " with Alt/Tab Window Picker| using keyboard shortcut: [alt]+[shift]+[s]")

$SettingsButton = GUICtrlCreateButton("", 40, 128, 40, 33, $BS_icon) ;was 195 left
GUICtrlSetTip(-1, "Settings")
GUICtrlSetImage($SettingsButton, "shell32.dll", 274)

Local const $GoButton_tooltip = "Using the Go button or the overrides in the popout menu, Loginmajig"&@CRLF& _
								"sends the keys to the window with the title specified in the Target box" & @CRLF & @CRLF & _
								"Using the hotkeys always sends to the current window."
;If 1 Then ;for testing xp style
If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Then
	$GoButton = GUICtrlCreateButton("Go!", 230, 128, 80, 33)
	GUICtrlSetTip(-1, $GoButton_tooltip)
	$OverridesButton = GUICtrlCreateButton("Overrides", 315, 130, 50, 29)
	GUICtrlSetFont(-1, 8)
Else
	$GoButton = GUICtrlCreateButton("Go!", 245, 128, 100, 33, $BS_SPLITBUTTON)
	GUICtrlSetTip(-1, $GoButton_tooltip)
	$OverridesButton =99999 ;so that the switch doesn't complain
EndIf

$StatusBar1 = _GUICtrlStatusBar_Create($gui_main)
_GUICtrlStatusBar_SetMinHeight($StatusBar1, 25)
GUISetState(@SW_SHOW)

; ================= SETTINGS GUI ===================
$gui_options = GUICreate("Loginmajig Settings", 418, 301, 271, 155, -1, -1, $gui_main)
$Group1 = GUICtrlCreateGroup("Hotkeys", 16, 8, 385, 165)
$Label1 = GUICtrlCreateLabel("Not all key combinations are valid, and generally require at least an alt or ctrl. If another app is already using this hotkey combo, it won't accept the combo."&@CRLF&"Click in a box below to set a hotkey.", 26, 26, 365, 40)

$Label2 = GUICtrlCreateLabel("Send Domain\Username && Password", 32, 82, 190, 17, $SS_RIGHT)
;$Input1 = GUICtrlCreateInput("Input1", 184, 78, 120, 21)
$hHotkey_dup = __CreateHotkeyInput(230, 78, 120, 21, $gui_options)
$Label3 = GUICtrlCreateLabel("Send Username && Password", 32, 114, 190, 17, $SS_RIGHT)
;$Input2 = GUICtrlCreateInput("Input1", 184, 110, 120, 21)
$hHotkey_up = __CreateHotkeyInput(230, 110, 120, 21, $gui_options)
$Label4 = GUICtrlCreateLabel("Send Password Only", 32, 146, 190, 17, $SS_RIGHT)
;$Input3 = GUICtrlCreateInput("Input1", 184, 142, 120, 21)
$hHotkey_p = __CreateHotkeyInput(230, 142, 120, 21, $gui_options)

__SetHotkeyVal($hHotkey_dup, $settings_hotkey_dup)
__SetHotkeyVal($hHotkey_up, $settings_hotkey_up)
__SetHotkeyVal($hHotkey_p, $settings_hotkey_p)

local Const $KeySpeedTip = "Set the key speed lower if you have a bad"&@CRLF&"connection, or for RDPception (rdp inside rdp ;)"
$Group2 = GUICtrlCreateGroup("Key Speed", 16, 176, 385, 49)
$gKeySpeedSlider = GUICtrlCreateSlider(80, 190, 160, 33)
GUICtrlSetLimit(-1, 200, 10) ;max, min... wtf autoit?
GUICtrlSetData(-1, $settings_keyspeed) ;$settings_keyspeed is the default atm
GUICtrlSetTip(-1, $KeySpeedTip)
$gKeySpeed = GUICtrlCreateInput("100", 248, 194, 41, 21)
GUICtrlSetTip(-1, $KeySpeedTip)
$gKeySpeedLabel = GUICtrlCreateLabel("ms / key", 296, 196, 45, 17)
GUICtrlSetTip(-1, $KeySpeedTip)
GUICtrlCreateGroup("", -99, -99, 1, 1)

$cAutodetect2003 = GUICtrlCreateCheckbox("Try to autodetect server 2003 (&& not send the 'domain\')", 32, 230, 300, 33)
GUICtrlSetState(-1, $GUI_CHECKED)
Global $settings_Autodetect2003 = True

$BtnOK = GUICtrlCreateButton("OK", 248, 272, 73, 25)
$BtnCancel = GUICtrlCreateButton("Cancel", 328, 272, 73, 25)

$about_link = GUICtrlCreateLabel("About Loginmajig", 40, 270, 85, 22)
GUICtrlSetColor(-1,0x0000FF)
GUICtrlSetFont(-1, -1, -1, 4)
GUICtrlSetCursor(-1, 0)

; ================= APP STARTUP ===================

_GUICtrlStatusBar_SetText($StatusBar1, "Checking for updates...")

Local $sData = InetRead("http://gatt.ca/updates/updates.php?product=loginmajig&what=version")
If(Number($lmj_version) < Number(BinaryToString($sData))) Then
	MsgBox(4096, "", "New Version! Click OK to download...")
	ShellExecute(BinaryToString(InetRead("http://gatt.ca/updates/updates.php?product=loginmajig&what=version_url")))
EndIf

_GUICtrlStatusBar_SetText($StatusBar1, "Preparing resources...")
FileInstall("ImgSearch\ImageSearchDLL.dll", @TempDir&"\ImageSearchDLL.dll")
FileInstall("ImgSearch\server2003.bmp", @TempDir&"\server2003.bmp")


_GUICtrlStatusBar_SetText($StatusBar1, "Registering Hotkeys...")
RegisterHotkeys()
SetKeySpeed()

_GUICtrlStatusBar_SetText($StatusBar1, "Setting up window grabber...")
AdlibRegister("TitleGrabber", 250)

; Prepare some global stuff..
Opt("SendKeyDelay",$settings_keyspeed/2)
Opt("SendKeyDownDelay",$settings_keyspeed/2)

$DefaultPassChar = GUICtrlSendMsg($ctl_password, $EM_GETPASSWORDCHAR, 0, 0)
GUIRegisterMsg($WM_COMMAND, "My_WM_COMMAND") ;onchange for the dropdown
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY") ;handles popout menu on split button
_GUICtrlStatusBar_SetText($StatusBar1, "Ready")

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $GoButton
			SendLogin()
		Case $OverridesButton
			ConsoleWrite("Popup menu button" & @CRLF)
			_Popup_Menu(GUICtrlGetHandle($OverridesButton))
			ConsoleWrite("Back from popup" & @CRLF)

		Case $cMaskPassword
			if(GUICtrlRead($cMaskPassword) == $GUI_CHECKED ) Then
				_GuiCtrlEditChangePasswordChar($ctl_password, True)
			else
				_GuiCtrlEditChangePasswordChar($ctl_password, False)
			EndIf
		Case $SettingsButton
			GUISetState(@SW_DISABLE, $gui_main)
			RegisterHotkeys(True) ;unregister
			$settings_Autodetect2003 = GUICtrlRead($cAutodetect2003)
			$settings_hotkey_dup = __GetHotkeyVal($hHotkey_dup)
			$settings_hotkey_up = __GetHotkeyVal($hHotkey_up)
			$settings_hotkey_p = __GetHotkeyVal($hHotkey_p)
			$settings_keyspeed = GUICtrlRead($gKeySpeedSlider)
			GUISetState(@SW_SHOW, $gui_options)
			local $iSliderPrevVal = 100 ;note it's good to have this here so the slider gets updated to a custom position, as appropriate
			local $iKeyValPrev = $iSliderPrevVal
			While 1
				;Update the slider if changed
				$iSliderNewVal = GUICtrlRead($gKeySpeedSlider)
				if $iSliderNewVal <> $iSliderPrevVal then
					ConsoleWrite("Slider val changed, = "&$iSliderNewVal & @CRLF)
					GUICtrlSetData($gKeySpeed, $iSliderNewVal)
					$iSliderPrevVal = $iSliderNewVal
				endif
				;Update the slider if the inputbox changed
				$iKeyValNew = GUICtrlRead($gKeySpeed)
				if $iKeyValNew <> $iKeyValPrev then
					ConsoleWrite("Key speed val changed, = "&$iKeyValNew & @CRLF)
					GUICtrlSetData($gKeySpeedSlider, $iKeyValNew)
					$iKeyValPrev = $iKeyValNew
				endif
				$msg = GUIGetMsg()
				Switch $msg
					Case $GUI_EVENT_CLOSE, $BtnCancel, $BtnOK
						GUISetState(@SW_HIDE, $gui_options)
						GUISetState(@SW_ENABLE, $gui_main)
						WinActivate($gui_main)
						if($msg == $BtnCancel )Then ;Reset the settings GUI
							__SetHotkeyVal($hHotkey_dup, $settings_hotkey_dup)
							__SetHotkeyVal($hHotkey_up, $settings_hotkey_up)
							__SetHotkeyVal($hHotkey_p, $settings_hotkey_p)
							if($settings_Autodetect2003) Then
								GUICtrlSetState($cAutodetect2003, $GUI_CHECKED)
							Else
								GUICtrlSetState($cAutodetect2003, $GUI_UNCHECKED)
							EndIf
							GUICtrlSetData($gKeySpeedSlider, $settings_keyspeed)
						EndIf
						RegisterHotkeys()
						SetKeySpeed()
						ExitLoop
					Case $about_link
						if(_IsPressed('4B')) Then
							ShellExecute("www.thewebsiteisdown.com")
						Else
							ShellExecute("www.gatt.ca/wiki/Loginmajig")
						EndIf
				EndSwitch
			WEnd
	EndSwitch
WEnd

func SetKeySpeed()
	$settings_keyspeed = GUICtrlRead($gKeySpeedSlider)
	Opt("SendKeyDelay",$settings_keyspeed/2)
	Opt("SendKeyDownDelay",$settings_keyspeed/2)
EndFunc

Func TitleGrabber()
	Local $TitleGrabber_new
	$hwnd= WinGetHandle("[active]")
	$TitleGrabber_new = WinGetTitle($hwnd)
	if $TitleGrabber_new <> $TitleGrabber_last Then ; skip everything if it's the same window
		$TitleGrabber_prev_window = $TitleGrabber_last
		$TitleGrabber_last = $TitleGrabber_new
		if StringInStr($TitleGrabber_new, "Remote Desktop Con") or _WinAPI_GetClassName($hwnd) == "rfb::win32::DesktopWindowClass" then ;match!
			GUICtrlSetData($ctl_sendto, $TitleGrabber_new)
		Else
			;GUICtrlSetData($ctl_sendto, $TitleGrabber_new)
		EndIf
	EndIf
EndFunc

func RegisterHotkeys($unregister=0)
	if($unregister) Then
		HotKeySet(__GetHotkeyVal($hHotkey_dup))
		HotKeySet(__GetHotkeyVal($hHotkey_up))
		HotKeySet(__GetHotkeyVal($hHotkey_p))
	Else
		if(Not HotKeySet(__GetHotkeyVal($hHotkey_dup), "hotkey_func_dup")) Then MsgBox(16, "Error setting Hotkey", "There was an error setting your hotkey for sending Domain, User, Password. No hotkey has been registered for this function; open the settings dialog to try again.")
		if(Not HotKeySet(__GetHotkeyVal($hHotkey_up), "hotkey_func_up")) Then MsgBox(16, "Error setting Hotkey", "There was an error setting your hotkey for sending User & Password. No hotkey has been registered for this function; open the settings dialog to try again.")
		if(Not HotKeySet(__GetHotkeyVal($hHotkey_p), "hotkey_func_p")) Then MsgBox(16, "Error setting Hotkey", "There was an error setting your hotkey for sending Password only. No hotkey has been registered for this function; open the settings dialog to try again.")
	EndIf
EndFunc

func hotkey_func_dup()
	GUICtrlSetData($ctl_sendto, $TitleGrabber_last)
	SendLogin($SEND_DOMAIN_USER_PASS)
EndFunc
func hotkey_func_up()
	GUICtrlSetData($ctl_sendto, $TitleGrabber_last)
	SendLogin($SEND_USER_PASS)
EndFunc
func hotkey_func_p()
	GUICtrlSetData($ctl_sendto, $TitleGrabber_last)
	SendLogin($SEND_PASS_ONLY)
EndFunc


Func SendLogin($opt=0)
	WinActivate(GUICtrlRead($ctl_sendto))
	if WinWaitActive(GUICtrlRead($ctl_sendto), "", 2) == 0 Then
		MsgBox(4096, "Oh noes!", "Something went wrong & Loginmajig couldn't find that target window!")
	else
		if($settings_Autodetect2003) then
			_GUICtrlStatusBar_SetText($StatusBar1, "Deciding if this is server 2003 & whether to send domain...")
			if(ImgSearch_for_Server2003(@TempDir&"\ImageSearchDLL.dll", @TempDir&"\server2003.bmp")) then $opt = $SEND_USER_PASS ;override to skip the domain
		EndIf
		;GUICtrlSetStyle($ctl_password, $ES_PASSWORD)
		_GUICtrlStatusBar_SetText($StatusBar1, "Sending keys... (note: mouse/kb is disabled)")
		BlockInput(1)

		;Switch the password box to hidden characters
		_GuiCtrlEditChangePasswordChar($ctl_password, True)
		GUICtrlSetState($cMaskPassword, $GUI_CHECKED)
		ConsoleWrite("about to send info, opt = "&$opt&@CRLF)
		$username=GUICtrlRead($ctl_username)
		if(($opt==0) or ($opt==$SEND_DOMAIN_USER_PASS) or ($opt==$SEND_USER_PASS)) then
			if(Not($username=="domain\user (opt)" or $username=="")) Then
				if($opt == $SEND_USER_PASS) Then
					Send(StringTrimLeft($username, StringInStr($username, "\")), 1)
					Send("{TAB}")
				Else
					if((GUICtrlRead($cSendUsername) == $GUI_CHECKED) or ($opt == $SEND_DOMAIN_USER_PASS)) Then
						Send($username, 1)
						Send("{TAB}")
					EndIf
				EndIf
				;ConsoleWrite("sending tab"&@crlf)
			EndIf
		EndIf
		$password=GUICtrlRead($ctl_password)
		Send($password, 1)
		Send("{ENTER}")
		;fix for shift/alt getting stuck sometimes
		ConsoleWrite("Sticky shift fix"&@CRLF)
		send("{SHIFTDOWN}")
		send("{SHIFTUP}")
		;ConsoleWrite("AltDown"&@CRLF)
		;send("{ALTDOWN}")
		;ConsoleWrite("AltUp"&@CRLF)
		;send("{ALTUP}")
		ConsoleWrite("UnBlock Input"&@CRLF)
		BlockInput(0)
		_GUICtrlStatusBar_SetText($StatusBar1, "Done! (mouse/kb re-enabled)")

		;_ArrayDisplay($login_creds)
		;add to the settings array...
		if(Not($username=="domain\user (opt)" or $username=="")) Then ;if no user lets not bother
			;check if this entry already exists, and update as needed
			$pos=-1;
			for $x=0 to UBound($login_creds)-1
				if($login_creds[$x][0]==$username) Then
					$pos=$x ;found a match, let's just update this one in stead of making a new one
					ExitLoop
				EndIf
			Next


			$new_creds[0][0]=$username
			$new_creds[0][1]=GUICtrlRead($cSendUsername)
			if(Not($new_creds[0][1]==1)) Then
				$new_creds[0][1]=0
			EndIf
			$new_creds[0][2]=$password
			if($pos==-1) Then
				__ArrayConcatenate($login_creds, $new_creds)
			Else
				;MsgBox(0,'BINGO', 'BINGO!! pos='&$pos)
				;_ArrayDisplay($login_creds)

				$login_creds[$pos][0]=$new_creds[0][0]
				$login_creds[$pos][1]=$new_creds[0][1]
				$login_creds[$pos][2]=$new_creds[0][2]

				#cs
				$login_creds[$pos][0]='replaced'
				$login_creds[$pos][1]=1
				$login_creds[$pos][2]='replaced'

				$login_creds[$pos][0]=$new_creds[0]
				$login_creds[$pos][1]=$new_creds[1]
				$login_creds[$pos][2]=$new_creds[2]
				#ce
			EndIf
			;generate new dropdown list
			$user_list=''
			for $x=0 to UBound($login_creds)-1
				$user_list&='|'&$login_creds[$x][0]
			Next

			GUICtrlSetData($ctl_username, $user_list, $username)

		EndIf
	EndIf
EndFunc

Func My_WM_COMMAND($hWnd, $imsg, $iwParam, $ilParam)
	Global $Combo1, $Input1
	Global $ctl_username, $ctl_password, $user_list, $cSendUsername, $cMaskPassword, $DefaultPassChar
    Local $setHK = False
    $nNotifyCode = BitShift($iwParam, 16)
    $nID = BitAND($iwParam, 0x0000FFFF)
    $hCtrl = $ilParam

    Switch $nNotifyCode
		case $CBN_SELCHANGE
			If $hCtrl = GUICtrlGetHandle($ctl_username) Then
				$iIndex=_GUICtrlComboBox_GetCurSel($ctl_username)
				GUICtrlSetData($ctl_username, $user_list, $login_creds[$iIndex][0])
				if($login_creds[$iIndex][1]) Then
					GUICtrlSetState( $cSendUsername, $GUI_CHECKED )
				Else
					GUICtrlSetState( $cSendUsername, $GUI_UNCHECKED )
				EndIf
				;Switch the password box to hidden characters
				_GuiCtrlEditChangePasswordChar($ctl_password, True)
				GUICtrlSetData($ctl_password, $login_creds[$iIndex][2])
				GUICtrlSetState($cMaskPassword, $GUI_CHECKED)
			EndIf
		case $CBN_EDITCHANGE
			If $hCtrl = GUICtrlGetHandle($ctl_username) Then
				_GuiCtrlEditChangePasswordChar($ctl_password, False)
				GUICtrlSetState( $cMaskPassword, BitOR($GUI_ENABLE, $GUI_UNCHECKED) )
			EndIf
		case $EN_CHANGE
			If $hCtrl = GUICtrlGetHandle($ctl_password) Then
				_GuiCtrlEditChangePasswordChar($ctl_password, False)
				GUICtrlSetState( $cMaskPassword, BitOR($GUI_ENABLE, $GUI_UNCHECKED) )
			EndIf
	EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc  ;==>My_WM_COMMAND

Func WM_NOTIFY($hWnd, $Msg, $wParam, $lParam)

    #forceref $hWnd, $Msg, $wParam

    Local $tNMBHOTITEM = DllStructCreate("hwnd hWndFrom;int IDFrom;int Code;dword dwFlags", $lParam)
    Local $nNotifyCode = DllStructGetData($tNMBHOTITEM, "Code")
    ;Local $nID = DllStructGetData($tNMBHOTITEM, "IDFrom")
    Local $hCtrl = DllStructGetData($tNMBHOTITEM, "hWndFrom")
    ;Local $dwFlags = DllStructGetData($tNMBHOTITEM, "dwFlags")

    Switch $nNotifyCode
        Case $BCN_DROPDOWN
            _Popup_Menu($hCtrl)
    EndSwitch

    Return $GUI_RUNDEFMSG

EndFunc   ;==>WM_NOTIFY

Func _Popup_Menu($hCtrl)

    Local $hMenu
    Local Enum $id_Ovr_dup = 1000, $id_Ovr_up, $id_Ovr_p, $idTarget
    $hMenu = _GUICtrlMenu_CreatePopup(16) ;16 = no space reserved for icon/checkmark
	if $hMenu == 0 Then
		ConsoleWrite("Popup menu creation failed!?" & @CRLF)
	EndIf
    _GUICtrlMenu_InsertMenuItem($hMenu, 0, "Force send: domain\user && Password", $id_Ovr_dup)
    _GUICtrlMenu_InsertMenuItem($hMenu, 1, "Force send: User && Password (no domain)", $id_Ovr_up)
    _GUICtrlMenu_InsertMenuItem($hMenu, 2, "Force send: Password only", $id_Ovr_p)
    _GUICtrlMenu_InsertMenuItem($hMenu, 3, "", 0) ;separator
    _GUICtrlMenu_InsertMenuItem($hMenu, 4, "Override: Set target to last window", $idTarget)
	Switch _GUICtrlMenu_TrackPopupMenu($hMenu, $hCtrl, -1, -1, 1, 1, 2)
        Case $id_Ovr_dup
            ConsoleWrite("Override: Sending Domain\User & Pass" & @CRLF)
			SendLogin($SEND_DOMAIN_USER_PASS)
        Case $id_Ovr_up
            ConsoleWrite("Override: Sending User & Pass" & @CRLF)
			SendLogin($SEND_USER_PASS)
        Case $id_Ovr_p
            ConsoleWrite("Override: Sending Pass only" & @CRLF)
			SendLogin($SEND_PASS_ONLY)
        Case $idTarget
            ConsoleWrite("Override: Set target to last window" & @CRLF)
			GUICtrlSetData($ctl_sendto, $TitleGrabber_prev_window)
    EndSwitch
	_GUICtrlMenu_DestroyMenu($hMenu)

EndFunc   ;==>_Popup_Menu
#cs
Func IsVisible($handle)
	If BitAnd( WinGetState($handle), 2 ) Then
		Return True
	Else
		Return False
	EndIf
EndFunc
#ce
Func _GuiCtrlEditChangePasswordChar(ByRef $h_edit, $b_hidepw)
    Local const $EM_SETPASSWORDCHAR = 0xCC
    GUISetState(@SW_LOCK)
    GUICtrlSetStyle($h_edit, $ES_PASSWORD ,$WS_EX_CLIENTEDGE)
	if($b_hidepw) Then
		GUICtrlSendMsg($h_edit, $EM_SETPASSWORDCHAR, $DefaultPassChar, 0)
	Else
		GUICtrlSendMsg($h_edit, $EM_SETPASSWORDCHAR, 0, 0)
	EndIf
    GUISetState(@SW_UNLOCK)
EndFunc