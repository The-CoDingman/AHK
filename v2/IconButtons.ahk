;///////////////////////////////////////////////////////////////////////////////////////////
; This script is designed to showcase creating image buttons for a GUI in AHK
; It works with multiple image types. I know it can at least use .PNG, .JPG, .JPEG, .BMP, .GIF (Will not animate)
; 
; Special thanks to Fanatic Guru who built the original function, please refer to the board topic at the link below for more information on it
;	https://www.autohotkey.com/boards/viewtopic.php?p=11390#p11390
;///////////////////////////////////////////////////////////////////////////////////////////


;Script Environment Settings
;///////////////////////////////////////////////////////////////////////////////////////////
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent
;///////////////////////////////////////////////////////////////////////////////////////////


;Prompt user about loading custom icons (Not Shell32.dll or ImageRes.dll icons)
;///////////////////////////////////////////////////////////////////////////////////////////
if (MsgBox("Would you like to load Custom Icons as well?", "Custom Image Buttons", "262148") = "Yes") {
	CustomIcons := 1
	CustomIconFolder := DirSelect(, 3, "Choose the directory where your Custom Icons are stored")
}
;///////////////////////////////////////////////////////////////////////////////////////////


;Begin desiging the GUI and loading the icons, this step takes some time because we're loading a minimium of 1,326 image buttons
;///////////////////////////////////////////////////////////////////////////////////////////
IconGui := Gui("-Theme")
IconGui.OnEvent("Close", (*) => ExitApp())
if ((CustomIcons ?? 0) = 1) {
	TabControl := IconGui.Add("Tab3", "xm ym w1365 h985", ["Shell32.dll GUI Theme: ON", "Shell32.dll GUI Theme: OFF", "Imageres.dll GUI Theme: ON", "Imageres.dll GUI Theme: OFF", "Custom Icons GUI Theme: ON", "Custom Icons GUI Theme: OFF"])
}
else {
	TabControl := IconGui.Add("Tab3", "xm ym w1365 h985", ["Shell32.dll GUI Theme: ON", "Shell32.dll GUI Theme: OFF", "Imageres.dll GUI Theme: ON", "Imageres.dll GUI Theme: OFF"])
}

;-------------------------------------------------------------------------------------------
;Load shell32.dll icons

CurrX := 10, CurrY := 30
IconCount := 0
IconGui.Opt("+Theme")
TabControl.UseTab(1)
Loop(329) {
	IconCount += 1
	IconText:= IconGui.Add("Text", "xm+" CurrX " ym+" CurrY, IconCount ".")
	CurrX += 25
	IconButton := IconGui.Add("Button", "xm+" CurrX " ym+" CurrY " h45 w45")
	GuiButtonIcon(IconButton.Hwnd, "shell32.dll", IconCount, "h40 w40")
	CurrX += 50
	if (CurrX > 1350) {
		CurrX := 10, CurrY += 50
	}
}

CurrX := 10, CurrY := 30
IconCount := 0
IconGui.Opt("-Theme")
TabControl.UseTab(2)
Loop(329) {
	IconCount += 1
	IconText:= IconGui.Add("Text", "xm+" CurrX " ym+" CurrY, IconCount ".")
	CurrX += 25
	IconButton := IconGui.Add("Button", "xm+" CurrX " ym+" CurrY " h45 w45")
	GuiButtonIcon(IconButton.Hwnd, "shell32.dll", IconCount, "h40 w40")
	CurrX += 50
	if (CurrX > 1350) {
		CurrX := 10, CurrY += 50
	}
}

;-------------------------------------------------------------------------------------------
;Load imageres.dll icons

CurrX := 10, CurrY := 30
IconCount := 0
IconGui.Opt("+Theme")
TabControl.UseTab(3)
Loop(334) {
	IconCount += 1
	IconText:= IconGui.Add("Text", "xm+" CurrX " ym+" CurrY, IconCount ".")
	CurrX += 25
	IconButton := IconGui.Add("Button", "xm+" CurrX " ym+" CurrY " h45 w45")
	GuiButtonIcon(IconButton.Hwnd, "imageres.dll", IconCount, "h40 w40")
	CurrX += 50
	if (CurrX > 1350) {
		CurrX := 10, CurrY += 50
	}
}

CurrX := 10, CurrY := 30
IconCount := 0
IconGui.Opt("-Theme")
TabControl.UseTab(4)
Loop(334) {
	IconCount += 1
	IconText:= IconGui.Add("Text", "xm+" CurrX " ym+" CurrY, IconCount ".")
	CurrX += 25
	IconButton := IconGui.Add("Button", "xm+" CurrX " ym+" CurrY " h45 w45")
	GuiButtonIcon(IconButton.Hwnd, "imageres.dll", IconCount, "h40 w40")
	CurrX += 50
	if (CurrX > 1350) {
		CurrX := 10, CurrY += 50
	}
}

;-------------------------------------------------------------------------------------------
;Load Custom Icons

if ((CustomIcons ?? 0) = 1) {
	CurrX := 10, CurrY := 30
	IconCount := 0
	IconGui.Opt("+Theme")
	TabControl.UseTab(5)
	Loop Files, CustomIconFolder "\*.*", "F" {
		if (IconCount > 342) {
			Break
		}
		if (RegExMatch(A_LoopFileExt, "(jpg|JPG|gif|GIF|png|PNG|jpeg|JPEG|bmp|BMP|jfif|JFIF)$")) {
			IconCount += 1
			IconText:= IconGui.Add("Text", "xm+" CurrX " ym+" CurrY, IconCount ".")
			CurrX += 25
			IconButton := IconGui.Add("Button", "xm+" CurrX " ym+" CurrY " h45 w45")
			GuiButtonIcon(IconButton.Hwnd, CustomIconFolder "\" A_LoopFileName, , "h40 w40")
			CurrX += 50
			if (CurrX > 1350) {
				CurrX := 10, CurrY += 50
			}
		}
	}

	CurrX := 10, CurrY := 30
	IconCount := 0
	IconGui.Opt("-Theme")
	TabControl.UseTab(6)
	Loop Files, CustomIconFolder "\*.*", "F" {
		if (IconCount > 342) {
			Break
		}
		if (RegExMatch(A_LoopFileExt, "(jpg|JPG|gif|GIF|png|PNG|jpeg|JPEG|bmp|BMP|jfif|JFIF)$")) {
			IconCount += 1
			IconText:= IconGui.Add("Text", "xm+" CurrX " ym+" CurrY, IconCount ".")
			CurrX += 25
			IconButton := IconGui.Add("Button", "xm+" CurrX " ym+" CurrY " h45 w45")
			GuiButtonIcon(IconButton.Hwnd, CustomIconFolder "\" A_LoopFileName, , "h40 w40")
			CurrX += 50
			if (CurrX > 1350) {
				CurrX := 10, CurrY += 50
			}
		}
	}
}
IconGui.Show()
;///////////////////////////////////////////////////////////////////////////////////////////


;Function for attach the image to the button
;///////////////////////////////////////////////////////////////////////////////////////////
GuiButtonIcon(Hwnd, Filename, Index := 1, Options := "") {
	RegExMatch(Options, "i)w\K\d+", &W) ? W := W[] : W := 16
	RegExMatch(Options, "i)h\K\d+", &H) ? H := H[] : H := 16
	RegExMatch(Options, "i)s\K\d+", &S) ? W := H := S[] : S := 0
	RegExMatch(Options, "i)l\K\d+", &L) ? L := L[] : L := 0
	RegExMatch(Options, "i)t\K\d+", &T) ? T := T[] : T := 0
	RegExMatch(Options, "i)r\K\d+", &R) ? R := R[] : R := 0
	RegExMatch(Options, "i)b\K\d+", &B) ? B := B[] : B := 0
	RegExMatch(Options, "i)a\K\d+", &A) ? A := A[] : A := 4
	A_PtrSize ? "" Psz := 4 : Psz := A_PtrSize, A_PtrSize ? "" Ptr := "UInt" : Ptr := "Ptr"
	NumPut("ptr", 40, button_il := Buffer((20 + Psz), 0), 0)
	normal_il := DllCall("ImageList_Create", "UInt", W, "UInt", H, "UInt", 0x21, "UInt", 1, "UInt", 1)
	NumPut("ptr", normal_il, button_il, 0)	; Width & Height
	NumPut("UInt", L, button_il, 0 + Psz)	; Left Margin
	NumPut("UInt", T, button_il, 4 + Psz)	; Top Margin
	NumPut("UInt", R, button_il, 8 + Psz)	; Right Margin
	NumPut("UInt", B, button_il, 12 + Psz)	; Bottom Margin	
	NumPut("UInt", A, button_il, 16 + Psz)	; Alignment
	SendMessage(BCM_SETIMAGELIST := 5634, 0, button_il,, Hwnd)
	return IL_Add( normal_il, Filename, Index )
}
;///////////////////////////////////////////////////////////////////////////////////////////


;How to use in your script
;///////////////////////////////////////////////////////////////////////////////////////////
;Step 1: Create your GUI
;Step 2: Create your Button
;Step 3: Call the GuiButtonIcon() function
;-------------------------------------------------------------------------------------------

;To use a DLL Icon
;	Main := Gui()
;	ButtonName := Main.Add("Button", "xm ym w45 h45") ; I recommend NOT setting any text onto the button, if you want text I suggest using a tooltip on hover function
;	GuiButtonIcon(ButtonName.Hwnd, "shell32.dll", 1, "h40 w40") ; I recommend setting the Height/Width to be about 5 pixels smaller than your button to create a buffer and avoid clipping
	
;To use a Custom image
;	Main := Gui()
;	ButtonName := Main.Add("Button", "xm ym w45 h45") ; I recommend NOT setting any text onto the button, if you want text I suggest using a tooltip on hover function
;	GuiButtonIcon(ButtonName.Hwnd, "C:\image.png", , "h40 w40") ; I recommend setting the Height/Width to be about 5 pixels smaller than your button to create a buffer and avoid clipping	
;///////////////////////////////////////////////////////////////////////////////////////////
