#include-once
#include <array.au3>

If @ScriptName = "ImgSearch.au3" Then

	;for testing
	HotKeySet("!+s", "__ImgSearch_test")
	HotKeySet("!+q", "__ImgSearch_quitapp")

	while 1
	WEnd

EndIf

func __ImgSearch_test()
	ImgSearch_for_Server2003("ImageSearchDLL.dll", "server2003.bmp")
EndFunc

func __ImgSearch_quitapp()
	Exit
EndFunc

Func ImgSearch_for_Server2003($dllpath, $imgpath)
	;Const $ImgFName = "server2003.bmp"
	;Const $ImgFName = "fffffffffffffffserver2003.bmp"

	Const $tolerance = 40

	Local $WindowSize = WinGetPos("[active]")
	;MsgBox(0, "Active window stats (x,y,width,height):", $WindowSize[0] & " " & $WindowSize[1] & " " & $WindowSize[2] & " " & $WindowSize[3])

	$result = DllCall($dllpath, "str", "ImageSearch", "int", $WindowSize[0], "int", $WindowSize[1], "int", $WindowSize[0]+$WindowSize[2], "int", $WindowSize[1]+$WindowSize[3], "str", "*"&$tolerance&" *transwhite "&$imgpath)
	If IsArray($result) Then
		;_ArrayDisplay($result)
		if($result[0]<>0) Then
			$result = StringSplit($result[0],"|")
			;_ArrayDisplay($result)
			ConsoleWrite("Sick, found a 2003 style login box at "&$result[2]&", "&$result[3]&@CRLF)
			return true
		Else
			;_ArrayDisplay($result)
			ConsoleWrite("ImgSearch couldn't find a 2003 style login box in the current window."&@CRLF)
			return False
		EndIf
	Else
		ConsoleWrite("ImgSearch couldn't find a 2003 style login box in the current window."&@CRLF)
		;MsgBox(0, "message", "imagesearch returned: " & $result)
		return False
	EndIf
EndFunc