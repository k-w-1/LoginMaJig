#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon\loginmajig_all2.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Fileversion=1.3.0.0
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

Const $lmj_version=1.3
Const $sHotKey="+!s"

#Region ### START Koda GUI section ### Form=
$Form1_1 = GUICreate("Loginmajig v" & $lmj_version, 371, 201, 251, 142, $GUI_SS_DEFAULT_GUI)
$Label1 = GUICtrlCreateLabel("Username:", 16, 20, 55, 17, $SS_RIGHT)
$ctl_username = GUICtrlCreateCombo("domain\user (opt)", 76, 16, 220, 25)
GUICtrlSetTip(-1, "If left blank, LMJ will skip sending the username")
$cSendUsername = GUICtrlCreateCheckbox("Send", 304, 18, 49, 17)
GUICtrlSetState( -1, $GUI_CHECKED )
$Label2 = GUICtrlCreateLabel("Password:", 16, 52, 55, 17, $SS_RIGHT)
$ctl_password = GUICtrlCreateInput("", 76, 48, 220, 21, BitOR($ES_PASSWORD, $ES_AUTOHSCROLL))
$cMaskPassword = GUICtrlCreateCheckbox("Mask", 304, 50, 49, 17)
$Label3 = GUICtrlCreateLabel("Send:", 16, 92, 55, 17, $SS_RIGHT)
$ctl_sendto = GUICtrlCreateCombo(" to last window (use Alt/Tab to set)", 76, 88, 220, 25, $CBS_DROPDOWNLIST)
GUICtrlSetData(-1, " with Alt/Tab Window Picker| using keyboard shortcut: [alt]+[shift]+[s]")

$about_link = GUICtrlCreateLabel("About Loginmajig", 40, 140, 85, 22)
GUICtrlSetColor(-1,0x0000FF)
GUICtrlSetFont(-1, -1, -1, 4)
GUICtrlSetCursor(-1, 0)

$GoButton = GUICtrlCreateButton("Go!", 256, 128, 81, 33)
$StatusBar1 = _GUICtrlStatusBar_Create($Form1_1)
_GUICtrlStatusBar_SetMinHeight($StatusBar1, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


;Constants (all in msec)
Const $key_delay = 50
Const $window_switch_delay = 100

;Mouse click capture stuff
Dim Const $tagMSLLHOOKSTRUCT = $tagPOINT&';dword mouseData;dword flags;dword time;ulong_ptr dwExtraInfo'

dim $login_creds[1][3]

$login_creds[0][0]=' '
$login_creds[0][1]='1'
$login_creds[0][2]=''
$new_creds=$login_creds

_GUICtrlStatusBar_SetText($StatusBar1, "Checking for updates...")

Local $sData = InetRead("http://gatt.ca/updates/updates.php?product=loginmajig&what=version")
If($lmj_version < BinaryToString($sData)) Then
	MsgBox(4096, "", "New Version! Click OK to download...")
	ShellExecute(BinaryToString(InetRead("http://gatt.ca/updates/updates.php?product=loginmajig&what=version_url")))
EndIf

; Prepare some global stuff..
Opt("SendKeyDelay",$key_delay)
Opt("SendKeyDownDelay",$key_delay)
$DefaultPassChar = GUICtrlSendMsg($ctl_password, $EM_GETPASSWORDCHAR, 0, 0)
GUIRegisterMsg($WM_COMMAND, "My_WM_COMMAND") ;onchange for the dropdown
_GUICtrlStatusBar_SetText($StatusBar1, "Ready")

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $GoButton

			;input gets reenabled at the end of the sendlogin() anyway
			BlockInput(1)

			;Check where we're sending this to
			;for the moment we're going to assume alt/tab
			if(1) Then
				Send("!{TAB}")
			EndIf

			;should do a winwaitactive or something...
			Sleep($window_switch_delay)

			SendLogin()

		Case $cMaskPassword
			if(GUICtrlRead($cMaskPassword) == $GUI_CHECKED ) Then
				_GuiCtrlEditChangePasswordChar($ctl_password, True)
			else
				_GuiCtrlEditChangePasswordChar($ctl_password, False)
			EndIf
		Case $ctl_sendto
			if(_GUICtrlComboBox_GetCurSel($ctl_sendto)==2) Then
				if(HotKeySet($sHotKey, "SendLogin")==1) Then
					_GUICtrlStatusBar_SetText($StatusBar1, "Ready (hotkey "&$sHotKey&" registered)")
				Else
					_GUICtrlStatusBar_SetText($StatusBar1, "Hotkey registration failed =(")
				EndIf
			Elseif(_GUICtrlComboBox_GetCurSel($ctl_sendto)==2) Then
				_GUICtrlStatusBar_SetText($StatusBar1, "Alt-Tab picker not yet working...")

			Else
				HotKeySet($sHotKey)
				_GUICtrlStatusBar_SetText($StatusBar1, "Ready")
			EndIf

        Case $about_link
            ShellExecute("www.gatt.ca/wiki/Loginmajig")
	EndSwitch
WEnd

Func SendLogin()
	;GUICtrlSetStyle($ctl_password, $ES_PASSWORD)
	_GUICtrlStatusBar_SetText($StatusBar1, "Sending keys... (note: mouse/kb is disabled)")
	BlockInput(1)

	;Switch the password box to hidden characters
	_GuiCtrlEditChangePasswordChar($ctl_password, True)
	GUICtrlSetState($cMaskPassword, $GUI_CHECKED)




	$username=GUICtrlRead($ctl_username)
	if(Not($username=="domain\user (opt)" or $username=="")) Then
		if(GUICtrlRead($cSendUsername) == $GUI_CHECKED ) Then
			Send($username, 1)
			Send("{TAB}")
		EndIf
	EndIf
	$password=GUICtrlRead($ctl_password)
	Send($password, 1)
	Send("{ENTER}")
	;fix for shift/alt getting stuck sometimes
	send("{SHIFTDOWN}")
	send("{SHIFTUP}")
	send("{ALTDOWN}")
	send("{ALTUP}")
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

Func IsVisible($handle)
	If BitAnd( WinGetState($handle), 2 ) Then
		Return True
	Else
		Return False
	EndIf
EndFunc

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

Func Mouse_LL($iCode, $iwParam, $ilParam)
    Local $tMSLLHOOKSTRUCT = DllStructCreate($tagMSLLHOOKSTRUCT, $ilParam)

    If $iCode < 0 Then
        Return _WinAPI_CallNextHookEx($hHook, $iCode, $iwParam, $ilParam)
    EndIf

	If $iwParam = $WM_LBUTTONDOWN Then
		;som_update("left button detected!")
	EndIf

	Return _WinAPI_CallNextHookEx($hHook, $iCode, $iwParam, $ilParam)
EndFunc

Func MouseTracking($on=true)
	Global $hFunc, $pFunc, $hHook

	if($on==true) Then
		$hFunc = DllCallbackRegister("Mouse_LL", "long", "int;wparam;lparam")
		$pFunc = DllCallbackGetPtr($hFunc)
		$hHook = _WinAPI_SetWindowsHookEx($WH_MOUSE_LL, $pFunc, _WinAPI_GetModuleHandle(0))
	Else
		_WinAPI_UnhookWindowsHookEx($hHook)
		DllCallbackFree($hFunc)
	EndIf
EndFunc