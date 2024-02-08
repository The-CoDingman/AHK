#Requires AutoHotkey v2.0
OnMessage(0x0200, WM_MOUSEMOVE_ToggleButtons, 1)
OnMessage(0x201, WM_BUTTONDOWN_ToggleButtons, 1)
OnMessage(0x202, WM_BUTTONUP_ToggleButtons, 1)
OnMessage(0x203, WM_BUTTONDOWN_ToggleButtons, 1)
OnMessage(0x204, WM_BUTTONDOWN_ToggleButtons, 1)
OnMessage(0x205, WM_BUTTONUP_ToggleButtons, 1)

class ToggleButton {
    static FileFormat := ""
    static FileExtension := ""

    __New(CurrGui, Options, FileName) {
        FileFormat := ToggleButton.FileFormat
        FileExtension := RegExMatch(FileName, "(.(jpg|JPG|gif|GIF|png|PNG|jpeg|JPEG|bmp|BMP|jfif|JFIF)$)", &match) ? match[] : ToggleButton.FileExtension
        if (FileExtension = "") {
            throw ValueError("Invalid File Extension", -1, FileName)
        }
        defaultImg := StrReplace(FileName, FileExtension, "_default" FileExtension)
        hoverImg := StrReplace(FileName, FileExtension, "_hover" FileExtension)
        clickImg := StrReplace(FileName, FileExtension, "_click" FileExtension)
        if (A_IsCompiled) {
            FileFormat := "HBITMAP:"
            defaultImg := ToggleButton.LoadImageFromResource(defaultImg)
            hoverImg := ToggleButton.LoadImageFromResource(hoverImg)
            clickImg := ToggleButton.LoadImageFromResource(clickImg)
        }
        try CurrGui.Opt("+E0x02000000 +E0x00080000")
        x := RegExMatch(Options, "x(\s*|m|p|\+|\-)\K\d+", &match) ? match[] : CurrGui.MarginX, xMod := RegExMatch(Options, "x\K(m|p|\+|\-)", &match) ? match[] : ""
        y := RegExMatch(Options, "y(\s*|m|p|\+|\-)\K\d+", &match) ? match[] : CurrGui.MarginY, yMod := RegExMatch(Options, "y\K(m|p|\+|\-)", &match) ? match[] : ""
        this.Gui := CurrGui 
        this.default := CurrGui.Add("Picture", Options " x" xMod x " y" yMod y " +0x100 AltSubmit BackgroundTrans", FileFormat defaultImg)
        this.default.ToggleButton := 1, this.default.Obj := this
        this.hover := CurrGui.Add("Picture", Options " xp yp Hidden +0x100 AltSubmit BackgroundTrans", FileFormat hoverImg)
        this.hover.ToggleButton := 1, this.hover.Obj := this
        this.click := CurrGui.Add("Picture", Options " xp yp Hidden +0x100 AltSubmit BackgroundTrans", FileFormat clickImg)
        this.click.ToggleButton := 1, this.click.Obj := this
        this.IsActive := 0
        return this
    }

    Focus() {
        this.default.Focus()
    }

    GetPos(params*) {
        this.default.GetPos(&x, &y, &width, &height)
        try %params[1]% := x
        try %params[2]% := y
        try %params[3]% := width
        try %params[4]% := height
    }

    Move(params*) {
        try x := params[1]
        try y := params[2]
        try width := params[3]
        try height := params[4]
        this.default.Move(x?, y?, width?, height?)
        this.hover.Move(x?, y?, width?, height?)
        this.click.Move(x?, y?, width?, height?)
    }

    OnCommand(notifyCode, callback, addRemove := unset) {
        Try {
            this.default.OnCommand(notifyCode, (p*) => (p[1] := this, callback(p*)), addRemove?)
            this.hover.OnCommand(notifyCode, (p*) => (p[1] := this, callback(p*)), addRemove?)
            this.click.OnCommand(notifyCode, (p*) => (p[1] := this, callback(p*)), addRemove?)
        }
        Catch {
            throw ValueError("Invalid `"OnEvent`" parameter", -1, notifyCode)
        }
    }

    OnEvent(eventName, callback, addRemove := unset) {
        if (eventName = "Click") {
            this.OnClick := callback
        }
        else if (eventName = "DoubleClick") {
            this.OnDoubleClick := callback
        }
        else if (eventName = "ContextMenu") {
            this.OnContextMenu := callback
        }
        else {
            Try {
                this.hover.OnEvent(eventName, (p*) => (p[1] := this, callback(p*)), addRemove?)
            }
            Catch {
                throw ValueError("Invalid `"OnEvent`" parameter", -1, eventName)
            }
        }
	}

    OnNotify(notifyCode, callback, addRemove := unset) {
        this.default.OnNotify(notifyCode, (p*) => (p[1] := this, callback(p*)), addRemove?)
        this.hover.OnNotify(notifyCode, (p*) => (p[1] := this, callback(p*)), addRemove?)
        this.click.OnNotify(notifyCode, (p*) => (p[1] := this, callback(p*)), addRemove?)
        Try {
        }
        Catch {
            throw ValueError("Invalid `"OnEvent`" parameter", -1, notifyCode)
        }
    }

    Opt(options) {
        this.default.Opt(options)
        this.hover.Opt(options)
        this.click.Opt(options)
    }

    Redraw() {
        this.default.Redraw()
        this.hover.Redraw()
        this.click.Redraw()
    }

    SetFont(options*) {
        throw ValueError("Not supported for this control type.", -1)
    }

    ClassNN => ToggleButton.GetClassNN(this)
    static GetClassNN(CurrObj) {
        return [CurrObj.default.ClassNN, CurrObj.hover.ClassNN, CurrObj.click.ClassNN]
    }

    Enabled {
        get => ToggleButton.GetIsEnabled(this)
        set => ToggleButton.SetIsEnabled(this, Value)
    }
    static GetIsEnabled(CurrObj) {
        if (CurrObj.default.Enabled || CurrObj.hover.Enabled || CurrObj.click.Enabled) {
            return 1
        }
        return 0
    }
    static SetIsEnabled(CurrObj, Value) {
        CurrObj.default.Enabled := CurrObj.hover.Enabled := CurrObj.click.Enabled := Value
    }

    Focused => ToggleButton.GetIsFocused(this)
    static GetIsFocused(CurrObj) {
        If (CurrObj.default.Focused || CurrObj.hover.Focused || CurrObj.click.Focused) {
            return 1
        }
        return 0
    }

    Hwnd => ToggleButton.GetHwnd(this)
    static GetHwnd(CurrObj) {
        return [CurrObj.default.Hwnd, CurrObj.hover.Hwnd, CurrObj.click.Hwnd]
    }

    Name {
        get => ToggleButton.GetName(this)
        set => ToggleButton.SetName(this, Value)
    }
    static GetName(CurrObj) {
        return [CurrObj.default.Name, CurrObj.hover.Name, CurrObj.click.Name]
    }
    static SetName(CurrObj, Value) {
        CurrObj.default.Name := Value "_default"
        CurrObj.hover.Name := Value "_hover"
        CurrObj.click.Name := Value "_click"
    }

    Text {
        get => ToggleButton.GetText(this)
        set => ToggleButton.SetText(this, Value)
    }
    static GetText(CurrObj) {
        return [CurrObj.default.Text, CurrObj.hover.Text, CurrObj.click.Text]
    }
    static SetText(CurrObj, Value) {
        return ;You can set the value of a Gui.Pic's Text without an error being produced, but it doesn't actually change the value so we're just doing a flat return
    }

    Type := "ToggleButton"

    Value {
        get => ToggleButton.GetValue(this)
        set => ToggleButton.SetValue(this, Value)
    }
    static GetValue(CurrObj) {
        return [CurrObj.default.Value, CurrObj.hover.Value, CurrObj.click.Value]
    }
    static SetValue(CurrObj, FileName) {
        FileFormat := ToggleButton.FileFormat
        FileExtension := RegExMatch(FileName, "(.(jpg|JPG|gif|GIF|png|PNG|jpeg|JPEG|bmp|BMP|jfif|JFIF)$)", &match) ? match[] : ToggleButton.FileExtension
        if (FileExtension = "") {
            throw ValueError("Invalid File Extension", -1, FileName)
        }
        defaultImg := StrReplace(FileName, FileExtension, "_default" FileExtension)
        hoverImg := StrReplace(FileName, FileExtension, "_hover" FileExtension)
        clickImg := StrReplace(FileName, FileExtension, "_click" FileExtension)
        if (A_IsCompiled) {
            FileFormat := "HBITMAP:"
            defaultImg := ToggleButton.LoadImageFromResource(defaultImg)
            hoverImg := ToggleButton.LoadImageFromResource(hoverImg)
            clickImg := ToggleButton.LoadImageFromResource(clickImg)
        }
        CurrObj.default.Value := FileFormat defaultImg
        CurrObj.hover.Value := FileFormat hoverImg
        CurrObj.click.Value := FileFormat clickImg
    }

    Visible {
        get => ToggleButton.GetIsVisible(this)
        set => ToggleButton.SetIsVisible(this, Value)
    }
    static GetIsVisible(CurrObj) {
        if(CurrObj.default.Visible || CurrObj.hover.Visible || CurrObj.click.Visible) {
            return 1
        }
        return 0
    }
    static SetIsVisible(CurrObj, Value) {
        CurrObj.default.Visible := Value
        CurrObj.hover.Visible := 0
        CurrObj.click.Visible := 0
    }

    static LoadImageFromResource(ResourceName) {
        Loop {
            hModule := DllCall("GetModuleHandle", "Ptr", 0, "Ptr")
            Resource := DllCall("FindResource", "Ptr", hModule, "Str", ResourceName, "UInt", RT_RCDATA := 10, "Ptr")
            ResourceSize := DllCall("SizeofResource", "Ptr", hModule, "Ptr", Resource)
            ResourceData := DllCall("LoadResource", "Ptr", hModule, "Ptr", Resource, "Ptr")
            DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", ResourceData, "UInt", ResourceSize, "UInt", 0x01, "Ptr", 0, "UIntP", &B64Len := 0)
            VarSetStrCapacity(&B64, (B64Len << !!1))
            DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", ResourceData, "UInt", ResourceSize, "UInt", 0x01, "Str", B64, "UIntP", B64Len)
            ResourceData := ""
            VarSetStrCapacity(&ResourceData, 0)
            VarSetStrCapacity(&B64, -1)
            B64 := RegExReplace(B64, "\r\n")
            B64Len := StrLen(B64)
        
            if (!DllCall("Crypt32.dll\CryptStringToBinary", "Str", B64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", &DecLen := 0, "Ptr", 0, "Ptr", 0)) {
                return false
            }
            VarSetStrCapacity(&Dec, DecLen)
            if (!DllCall("Crypt32.dll\CryptStringToBinary", "Str", B64, "UInt", 0, "UInt", 0x01, "Str", Dec, "UIntP", &DecLen, "Ptr", 0, "Ptr", 0)) {
                return false
            }
        
            hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, "UPtr", DecLen, "UPtr")
            pData := DllCall("Kernel32.dll\GlobalLock", "Ptr", hData, "UPtr")
            DllCall("Kernel32.dll\RtlMoveMemory", "Ptr", pData, "Str", Dec, "UPtr", DecLen)
            DllCall("Kernel32.dll\GlobalUnlock", "Ptr", hData)
            DllCall("Ole32.dll\CreateStreamOnHGlobal", "Ptr", hData, "Int", true, "PtrP", &pStream := 0)
            hGdip := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
            SI := Buffer(16, 0), NumPut("Char", 1, SI)
            DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", &pToken := 0, "Ptr", SI, "Ptr", 0)
            DllCall("Gdiplus.dll\GdipCreateBitmapFromStream", "Ptr", pStream, "PtrP", &pBitmap := 0)
            DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "PtrP", &hBitmap := 0, "UInt", 0)
            DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", pBitmap)
            DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", pToken)
            DllCall("Kernel32.dll\FreeLibrary", "Ptr", hGdip)
            DllCall(NumGet(NumGet(pStream + 0, 0, "UPtr") + (A_PtrSize * 2), 0, "UPtr"), "Ptr", pStream)
            if (hBitmap != 0) {
                return hBitmap
            }
        }
    }
}

WM_MOUSEMOVE_ToggleButtons(wParam, lParam, Msg, Hwnd) {   
    ;ToolTip("Hwnd: " Hwnd "`nMainGui.Hwnd: " MainGui.Hwnd "`nToggleButton1_1.Hwnd: " ToggleButton1_1.Hwnd "`nToggleButton1_2.Hwnd: " ToggleButton1_2.Hwnd "`nToggleButton1_3.Hwnd: " ToggleButton1_3.Hwnd "`nToggleButton2_1.Hwnd: " ToggleButton2_1.Hwnd "`nToggleButton2_2.Hwnd: " ToggleButton2_2.Hwnd)
    static PrevHwnd := 0
    if (Hwnd != PrevHwnd) {
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        PrevControl := GuiCtrlFromHwnd(PrevHwnd)
        if (CurrControl.HasProp("ToggleButton")) {
            CurrObj := CurrControl.Obj
            if (CurrControl = CurrObj.default) && (CurrObj.IsActive != 1) {
                CurrObj.hover.visible := 1
                CurrObj.default.visible := 0
            }
        }
        else {
            if (PrevControl.HasProp("ToggleButton")) {
                CurrObj := PrevControl.Obj
                if (CurrObj.IsActive != 1) {
                    CurrObj.default.visible := 1
                    CurrObj.hover.visible := 0
                }
            }
        }
        PrevHwnd := Hwnd
    }
}

WM_BUTTONDOWN_ToggleButtons(wParam, lParam, Msg, Hwnd) {
    ;ToolTip("wParam: " wParam "`nlParam: " lParam "`nMsg: " Msg "`nHwnd: " Hwnd)
    CurrControl := GuiCtrlFromHwnd(Hwnd)
    if (CurrControl.HasProp("ToggleButton")) {
        CurrObj := CurrControl.Obj
        if (Msg = 513) {
            CurrObj.ClickType := "Click"
        }
        else if (Msg = 515) {
            CurrObj.ClickType := "DoubleClick"
        }
        else if (Msg = 516) {
            CurrObj.ClickType := "ContextMenu"
            return
        }
        else {
            CurrObj.ClickType := ""
            return
        }
        if (CurrObj.IsActive = 0) {
            CurrObj.click.visible := 1
            CurrObj.hover.visible := 0
            CurrObj.default.visible := 0
        }
        else if (CurrObj.IsActive = 1) {
            CurrObj.click.visible := 0
            CurrObj.hover.visible := 0
            CurrObj.default.visible := 1
        }
        CurrObj.IsActive := !CurrObj.IsActive
        return 0
    }
}

WM_BUTTONUP_ToggleButtons(wParam, lParam, Msg, Hwnd) {
    CurrControl := GuiCtrlFromHwnd(Hwnd)
    if (CurrControl.HasProp("ToggleButton")) {
        CurrObj := CurrControl.Obj
        if (CurrObj.ClickType = "Click") {
            try CurrObj.OnClick
        }
        else if (CurrObj.ClickType = "DoubleClick") {
            try CurrObj.OnDoubleClick
        }
        else if (CurrObj.ClickType = "ContextMenu") {
            try CurrObj.OnContextMenu
            return
        }
    }
}