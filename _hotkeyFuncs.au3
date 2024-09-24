#include <GUIConstantsEx.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>

;HotKeySet('{CAPSLOCK}', '_ExcludeHotkey')
;HotKeySEt('{NUMLOCK}', '_ExcludeHotkey')

Global Const $HKM_SETHOTKEY = $WM_USER + 1
Global Const $HKM_GETHOTKEY = $WM_USER + 2
Global Const $HKM_SETRULES = $WM_USER + 3

Global Const $HOTKEYF_ALT = 0x04
Global Const $HOTKEYF_CONTROL = 0x02
Global Const $HOTKEYF_EXT = 0x80; Extended key
Global Const $HOTKEYF_SHIFT = 0x01

; invalid key combinations
Global Const $HKCOMB_A = 0x8; ALT
Global Const $HKCOMB_C = 0x4; CTRL
Global Const $HKCOMB_CA = 0x40; CTRL+ALT
Global Const $HKCOMB_NONE = 0x1; Unmodified keys
Global Const $HKCOMB_S = 0x2; SHIFT
Global Const $HKCOMB_SA = 0x20; SHIFT+ALT
Global Const $HKCOMB_SC = 0x10; SHIFT+CTRL
Global Const $HKCOMB_SCA = 0x80; SHIFT+CTRL+ALT


Global $HotkeyMap
Dim $HotkeyMap[67][2]
$HotkeyMap[0][0] = "{CAPSLOCK}"
$HotkeyMap[0][1] = 20
$HotkeyMap[1][0] = "{NUMPAD0}"
$HotkeyMap[1][1] = 96
$HotkeyMap[2][0] = "{NUMPAD1}"
$HotkeyMap[2][1] = 97
$HotkeyMap[3][0] = "{NUMPAD2}"
$HotkeyMap[3][1] = 98
$HotkeyMap[4][0] = "{NUMPAD3}"
$HotkeyMap[4][1] = 99
$HotkeyMap[5][0] = "{NUMPAD4}"
$HotkeyMap[5][1] = 100
$HotkeyMap[6][0] = "{NUMPAD6}"
$HotkeyMap[6][1] = 101
$HotkeyMap[7][0] = "{NUMPAD7}"
$HotkeyMap[7][1] = 102
$HotkeyMap[8][0] = "{NUMPAD8}"
$HotkeyMap[8][1] = 103
$HotkeyMap[9][0] = "{NUMPAD8}"
$HotkeyMap[9][1] = 104
$HotkeyMap[10][0] = "{NUMPAD9}"
$HotkeyMap[10][1] = 105
$HotkeyMap[11][0] = "{NUMPADMULT}"
$HotkeyMap[11][1] = 106
$HotkeyMap[12][0] = "{NUMPADADD}"
$HotkeyMap[12][1] = 107
$HotkeyMap[13][0] = "{NUMPADSUB}"
$HotkeyMap[13][1] = 109
$HotkeyMap[14][0] = "{NUMPADDOT}"
$HotkeyMap[14][1] = 110
$HotkeyMap[15][0] = "{NUMPADDIV}"
$HotkeyMap[15][1] = 111
$HotkeyMap[16][0] = "{F1}"
$HotkeyMap[16][1] = 112
$HotkeyMap[17][0] = "{F2}"
$HotkeyMap[17][1] = 113
$HotkeyMap[18][0] = "{F3}"
$HotkeyMap[18][1] = 114
$HotkeyMap[19][0] = "{F4}"
$HotkeyMap[19][1] = 115
$HotkeyMap[20][0] = "{F5}"
$HotkeyMap[20][1] = 116
$HotkeyMap[21][0] = "{F6}"
$HotkeyMap[21][1] = 117
$HotkeyMap[22][0] = "{F7}"
$HotkeyMap[22][1] = 118
$HotkeyMap[23][0] = "{F8}"
$HotkeyMap[23][1] = 119
$HotkeyMap[24][0] = "{F9}"
$HotkeyMap[24][1] = 120
$HotkeyMap[25][0] = "{F10}"
$HotkeyMap[25][1] = 121
$HotkeyMap[26][0] = "{F11}"
$HotkeyMap[26][1] = 122
$HotkeyMap[27][0] = "{F12}"
$HotkeyMap[27][1] = 123
$HotkeyMap[28][0] = "{SCROLLLOCK}"
$HotkeyMap[28][1] = 145

;even though the buttons below don't have AU3 tags, they have different ASCII code
$HotkeyMap[29][0] = ";"
$HotkeyMap[29][1] = 186
$HotkeyMap[30][0] = "="
$HotkeyMap[30][1] = 187
$HotkeyMap[31][0] = "-"
$HotkeyMap[31][1] = 189
$HotkeyMap[32][0] = "."
$HotkeyMap[32][1] = 190
$HotkeyMap[33][0] = "/"
$HotkeyMap[33][1] = 191
$HotkeyMap[34][0] = "`"
$HotkeyMap[34][1] = 192
$HotkeyMap[35][0] = "["
$HotkeyMap[35][1] = 219
$HotkeyMap[36][0] = "\"
$HotkeyMap[36][1] = 220
$HotkeyMap[37][0] = "]"
$HotkeyMap[37][1] = 221
$HotkeyMap[38][0] = "'"
$HotkeyMap[38][1] = 222

$HotkeyMap[39][0] = "{HOME}"
$HotkeyMap[39][1] = 2084
$HotkeyMap[40][0] = "{END}"
$HotkeyMap[40][1] = 2083
$HotkeyMap[41][0] = "{INSERT}"
$HotkeyMap[41][1] = 2093
$HotkeyMap[42][0] = "{PGUP}"
$HotkeyMap[42][1] = 2081
$HotkeyMap[43][0] = "{PGDN}"
$HotkeyMap[43][1] = 2082
$HotkeyMap[44][0] = "{LEFT}"
$HotkeyMap[44][1] = 2085
$HotkeyMap[45][0] = "{RIGHT}"
$HotkeyMap[45][1] = 2087
$HotkeyMap[46][0] = "{UP}"
$HotkeyMap[46][1] = 2086
$HotkeyMap[47][0] = "{DOWN}"
$HotkeyMap[47][1] = 2088
$HotkeyMap[48][0] = "{NUMLOCK}"
$HotkeyMap[48][1] = 2192
$HotkeyMap[49][0] = ","
$HotkeyMap[49][1] = 188

; the following keys are either not currently possible to set, or they are duplicates depends on other system conditions, such as when NumLock is off
$HotkeyMap[50][0] = "{SCROLLLOCK}"
$HotkeyMap[50][1] = 3
$HotkeyMap[51][0] = "{BACKSPACE}"
$HotkeyMap[51][1] = 8
$HotkeyMap[52][0] = "{TAB}"
$HotkeyMap[52][1] = 9
$HotkeyMap[53][0] = "{NUMPAD5}"
$HotkeyMap[53][1] = 12
$HotkeyMap[54][0] = "{ENTER}"
$HotkeyMap[54][1] = 13
$HotkeyMap[55][0] = "{SPACE}"
$HotkeyMap[55][1] = 32
$HotkeyMap[56][0] = "{NUMPAD9}"
$HotkeyMap[56][1] = 33
$HotkeyMap[57][0] = "{NUMPAD3}"
$HotkeyMap[57][1] = 34
$HotkeyMap[58][0] = "{NUMPAD1}"
$HotkeyMap[58][1] = 35
$HotkeyMap[59][0] = "{NUMPAD7}"
$HotkeyMap[59][1] = 36
$HotkeyMap[60][0] = "{NUMPAD4}"
$HotkeyMap[60][1] = 37
$HotkeyMap[61][0] = "{NUMPAD8}"
$HotkeyMap[61][1] = 38
$HotkeyMap[62][0] = "{NUMPAD6}"
$HotkeyMap[62][1] = 39
$HotkeyMap[63][0] = "{NUMPAD2}"
$HotkeyMap[63][1] = 40
$HotkeyMap[64][0] = "{NUMPAD0}"
$HotkeyMap[64][1] = 45
$HotkeyMap[65][0] = "{NUMPADDOT}"
$HotkeyMap[65][1] = 46
$HotkeyMap[66][0] = "\"
$HotkeyMap[66][1] = 226

#cs ------------ example GUI --------------

$gui_Main = GUICreate('Get Hotkey', 220, 90)
$bt = GUICtrlCreateButton('See Value', 10, 50, 200, 30);
    GUICtrlSetState(-1, $GUI_DEFBUTTON)
$hHotkey = __CreateHotkeyInput(10, 10, 200, 25, $gui_Main)
GUISetState()

;Generate random hotkey
$key = ""
If Random(0,1,1) Then $key &= "^"
If Random(0,1,1) Then $key &= "!"
If Random(0,1,1) Then $key &= "+"
If Random(0,1,1) Then
    $key &= $HotkeyMap[Random(0,UBound($HotkeyMap, 1)-1, 1)][0]
Else
    $key &= Chr(Random(Asc("a"), Asc("z"), 1)) ;letter case is irrelevant
EndIf
MsgBox(0, "Generated default hotkey", $key)
__SetHotkeyVal($hHotkey, $key)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop
        Case $bt
            Msgbox(0, "Converted hotkey to AU3 format", __GetHotkeyVal($hHotkey))
 ;           If $i_Hotkey = 20 or $i_Hotkey = 144 then ;huh? What's wrong with CapsLock and F3?
 ;               _SendMessage($hWnd, $HKM_SETHOTKEY)
 ;           EndIf
    EndSwitch
WEnd
__DestroyHotkeyInput($hHotkey)
Exit

#ce ------------ end of example GUI --------------

Func __CreateHotkeyInput($iX,$iY, $iW,$iH, $hParentWnd)
	local $hWnd
	$hWnd = _WinAPI_CreateWindowEx(0, 'msctls_hotkey32', '', BitOR($WS_CHILD, $WS_VISIBLE), $iX, $iY, $iW, $iH, $hParentWnd)

	_SendMessage($hWnd, $HKM_SETRULES, _
		BitOR($HKCOMB_NONE, $HKCOMB_S), _                    ; invalid key combinations
		BitOR(BitShift($HOTKEYF_ALT, -16), BitAND(0, 0xFFFF))); add ALT to invalid entries
	return $hWnd
EndFunc

Func __DestroyHotkeyInput($hHotkey)
	_WinAPI_DestroyWindow ($hHotkey)
EndFunc

Func __GetHotkeyVal($hHotkey)
	Return HotkeyConvert(_SendMessage($hHotkey, $HKM_GETHOTKEY))
EndFunc

Func __SetHotkeyVal($hHotkey, $sHotKeyVal)
	_SendMessage($hHotkey, $HKM_SETHOTKEY, HotkeyConvert($sHotKeyVal, 1))
EndFunc

Func HotkeyConvert($hotkey, $type = 0)
    Local $key = ""
    Local $n = UBound($HotkeyMap, 1)-1
    Local $bin = 0
    If $type Then ;reverse convert AU3 to binary
        If StringInStr($hotkey, "+") Then $bin = BitOr($bin, $HOTKEYF_SHIFT)
        If StringInStr($hotkey, "^") Then $bin = BitOr($bin, $HOTKEYF_CONTROL)
        If StringInStr($hotkey, "!") Then $bin = BitOr($bin, $HOTKEYF_ALT)
        $hotkey = StringReplace(StringReplace(StringReplace($hotkey, "!", ""), "^", ""), "+", "") ;Removing any Shift/Ctrl/Alt
        For $i = 0 To $n Step 1
            If $HotkeyMap[$i][0] = $hotkey Then
                $key = $HotkeyMap[$i][1]
                ExitLoop
            EndIf
        Next
        If NOT $key Then
            $key = Asc(StringUpper($hotkey))
        EndIf
        $bin = "0x" & Hex(BitOr(0x100 * $bin, $key))
        Return $bin
    EndIf
  $n_Flag = BitShift($hotkey, 8); high byte
  $i_HotKey = BitAND($hotkey, 0x8FF); low byte this will include Home, Insert, etc without Shift, Ctrl and Alt
  $hotkeyAssignment = ''
  If BitAND($n_Flag, $HOTKEYF_SHIFT) Then $hotkeyAssignment &= '+'
  If BitAND($n_Flag, $HOTKEYF_CONTROL) Then $hotkeyAssignment &= '^'
  If BitAND($n_Flag, $HOTKEYF_ALT) Then $hotkeyAssignment &= '!'
    For $i = 0 TO $n Step 1
        If $HotkeyMap[$i][1] = $i_Hotkey Then
            $key = $HotkeyMap[$i][0]
            ExitLoop
        EndIf
    Next
    If NOT $key Then
    $i_HotKey = BitAND($hotkey, 0xFF)
    $key = StringLower(Chr($i_Hotkey)) ;any letter type of keys should be lower case to avoid confusion as capital "A" = Shift + a
    EndIf
    $hotkeyAssignment &= $key
    Return $hotkeyAssignment
EndFunc

Func _ExcludeHotkey()
    _SendMessage(_WinAPI_GetFocus(), $HKM_SETHOTKEY)
EndFunc