;Environment Controls
;///////////////////////////////////////////////////////////////////////////////////////////
#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ToggleButton.ahk
Persistent
;///////////////////////////////////////////////////////////////////////////////////////////

;Gui Creation
;///////////////////////////////////////////////////////////////////////////////////////////
MainGui := Gui("+LastFound -ToolWindow +Caption +E0x02000000 +E0x00080000")
MainGui.MarginX := 0, MainGui.MarginY := 0
MainGui.OnEvent("Close", (*) => ExitApp())

Button1 := ToggleButton(MainGui, "x10 y10", "Button1.bmp")
Button1.OnEvent("Click", (*) => CustomButtonClick("Click: Button1"))
Button1.OnEvent("DoubleClick", (*) => CustomButtonClick("DoubleClick: Button1"))
Button1.OnEvent("ContextMenu", (*) => CustomButtonClick("ContextMenu: Button1"))

Button2 := MainGui.Add("Button", "y+10", "Test")
Button2.OnEvent("Click", (*) => Reload())
Button2.OnEvent("DoubleClick", (*) => CustomButtonClick("DoubleClick: Button2"))
Button2.OnEvent("ContextMenu", (*) => ExitApp())

if (A_IsCompiled) {
    BackgroundImage := MainGui.Add("Picture", "x0 y0 w700 h600 0x200 AltSubmit BackgroundTrans", "HBITMAP:" ToggleButton.LoadImageFromResource("background.jpg"))
}
else {
    BackgroundImage := MainGui.Add("Picture", "x0 y0 w700 h600 0x200 AltSubmit BackgroundTrans", "background.jpg")
}
MainGui.Show("Center")
;///////////////////////////////////////////////////////////////////////////////////////////

;Callbacks
;///////////////////////////////////////////////////////////////////////////////////////////
CustomButtonClick(Msg) {
    Tooltip(Msg)
}
;///////////////////////////////////////////////////////////////////////////////////////////

;FileInstalls wrapped in a function we never refernce
;///////////////////////////////////////////////////////////////////////////////////////////
InternalResources() {
    FileInstall("Button1_default.bmp", "*")
    FileInstall("Button1_hover.bmp", "*")
    FileInstall("Button1_click.bmp", "*")
    FileInstall("background.jpg", "*")
}
;///////////////////////////////////////////////////////////////////////////////////////////