#Requires AutoHotkey v2.0
;///////////////////////////////////////////////////////////////////////////////////////////
;Array Extension
class _ArrayEx extends Array {
    static __New() {
        super.Prototype.Sort := ObjBindMethod(this, "Sort")
        super.Prototype.Contains := ObjBindMethod(this, "Contains")
    }

    static Sort(arr) {
        tempMap := Map()
        Loop(arr.length) {
            tempMap[arr[A_Index]] := "placeholder"
        }
        for k, v in tempMap {
            arr[A_Index] := k
        }
    }

    static Contains(haystack, needle) {
        for index, value in haystack {
            if (value = needle) {
                return index
            }
        }
        return false
    }
}

;-------------------------------------------------------------------------------------------
;GuiControl - Tab Extension

class _TabEx extends Gui.Tab {
    static __New() {
        this.TCIF_TEXT					:= 0x0001
		this.TCIF_IMAGE					:= 0x0002
        this.TCM_GETITEMCOUNT			:= 0x1304
        this.TCM_SETITEM				:= 0x133D
		this.TCM_GETIMAGELIST			:= 0x1302
		this.TCM_SETIMAGELIST			:= 0x1303
		this.SIZE						:= (5 * 4) + (2 * A_PtrSize) + (A_PtrSize - 4)
		this.OffTxP						:= (3 * 4) + (A_PtrSize - 4)
		this.OffImg						:= (3 * 4) + (A_PtrSize - 4) + A_PtrSize + 4
        super.Prototype.SetText			:= ObjBindMethod(this, "SetText")
		super.Prototype.SetIcon			:= ObjBindMethod(this, "SetIcon")
        super.Prototype.GetCount		:= ObjBindMethod(this, "GetCount")
		super.Prototype.GetImageList	:= ObjBindMethod(this, "GetImageList")
		super.Prototype.SetImageList	:= ObjBindMethod(this, "SetImageList")
    }

    static GetCount(TabCtrl) => SendMessage(this.TCM_GETITEMCOUNT, 0, 0, , TabCtrl.Hwnd)

    static SetText(TabCtrl, TabIndex, TabText) {                
        if (TabIndex < 0) || (TabIndex > TabCtrl.GetCount()) {
            return false
		}

        TCITEM := Buffer(this.Size)
        NumPut("UInt", this.TCIF_TEXT, TCITEM, 0)
        NumPut("Ptr", StrPtr(TabText), TCITEM, this.OffTxP)
        return SendMessage(this.TCM_SETITEM, (TabIndex - 1), TCITEM, , TabCtrl.Hwnd)
    }

	static SetIcon(TabCtrl, TabIndex, TabIcon) {
		if (TabIndex < 0) || (TabIndex > TabCtrl.GetCount()) {
			return false
		}
		iconList := this.GetImageList(TabCtrl)
		TCITEM := Buffer(this.Size, 0)
		NumPut("UInt", this.TCIF_IMAGE, TCITEM, 0)
		NumPut("Int", TabIcon - 1, TCITEM, this.OffImg)
		return SendMessage(this.TCM_SETITEM, (TabIndex - 1), TCITEM, , TabCtrl.Hwnd)
	}

	static SetImageList(TabCtrl, IL) {
		return SendMessage(this.TCM_SETIMAGELIST, 0, IL, , TabCtrl.Hwnd)
	}

	static GetImageList(TabCtrl) {
		return SendMessage(this.TCM_GETIMAGELIST, 0, 0, , TabCtrl.Hwnd)
	}
}

;-------------------------------------------------------------------------------------------
;Gui.Add Extension

class _GuiEx extends Gui {
    static __New() {
        super.Prototype.AddGif := ObjBindMethod(this, "AddGif")
    }

    static AddGif(CurrGui, Options, Value) {
        ControlAttributes := Map()
        Loop Parse Options, A_Space {
            OptionCheck(A_LoopField)
        }
        xPos := ControlAttributes.Has("xPos") ? ControlAttributes["xPos"] : "x" CurrGui.MarginX
        yPos := ControlAttributes.Has("yPos") ? ControlAttributes["yPos"] : "y" CurrGui.MarginY
        Width := ControlAttributes.Has("Width") ? ControlAttributes["Width"] : "ERROR"
        Height := ControlAttributes.Has("Height") ? ControlAttributes["Height"] : "ERROR"
        if (Width = "ERROR") {
            throw ValueError("Option 'Width' is required", -1)
        }
        if (Height = "ERROR") {
            ValueError("Option 'Height' is required", -1)
        }
        gWidth := "w" (SubStr(Width, 2) + 8), gHeight := "h" (SubStr(Height, 2) + 8)
        Name := ControlAttributes.Has("Name") ? ControlAttributes["Name"] : ""
        
        if !(WinGetExStyle(CurrGui.Hwnd) & 0x80) {
            CurrGui.Opt("+ToolWindow")
            TWS := 1
        }
        ctl := CurrGui.Add("Text", xPos " " yPos " " Width " " Height " " Name, "")
        CurrGui.Show("x-100000 y-100000")
        GifGui := Gui("-Caption -Theme -Border +Owner" ctl.Hwnd " +Parent" ctl.Hwnd) ;May need to split the +Owner and +Parent options onto their own lines
        ctl.Gif := GifGui.Add("ActiveX", "x-8 y-8 " gWidth " " gHeight, "about:blank"), ctl.Gif.wb := ctl.Gif.Value, ctl.Gif.doc := ctl.Gif.wb.Document
        ctl.Gif.doc.Write("<img id='Gif' src='" Value "'/><script>document.oncontextmenu = rightClick;function rightClick(e){e.preventDefault();}</script>")
        ctl.UpdateGif := UpdateGifPath
        GifGui.Show(Width " " Height)
        CurrGui.Hide()
        if (IsSet(TWS)) {
            CurrGui.Opt("-ToolWindow")
        }
        return ctl

        OptionCheck(Option) {
            if (RegExMatch(Option, "\bx", &match)) {
                ControlAttributes["xPos"] := RegExMatch(Option, "\b(x(?:\d+(*ACCEPT)|[sm](?![-+])\b(*ACCEPT)|[-+]{1,2}(?:m|\d+)(*ACCEPT)|p(?|[-+]\d+(*ACCEPT)|\b(*ACCEPT))|[sm]\+\d+(*ACCEPT))\b)", &match) ? match[] : "x" CurrGui.MarginX
            }
            else if (RegExMatch(Option, "\by", &match)) {
                ControlAttributes["yPos"] := RegExMatch(Option, "\b(y(?:\d+(*ACCEPT)|[sm](?![-+])\b(*ACCEPT)|[-+]{1,2}(?:m|\d+)(*ACCEPT)|p(?|[-+]\d+(*ACCEPT)|\b(*ACCEPT))|[sm]\+\d+(*ACCEPT))\b)", &match) ? match[] : "y" CurrGui.MarginY
            }
            else if (RegExMatch(Option, "\bw")) {
                ControlAttributes["Width"] := RegExMatch(Option, "\b(w\d+)", &match) ? match[] : "ERROR"
            }
            else if (RegExMatch(Option, "\bh")) {
                ControlAttributes["Height"] := RegExMatch(Option, "\b(h\d+)", &match) ? match[] : "ERROR"
            }
            else if (RegExMatch(Option, "\bv")) {
                ControlAttributes["Name"] := RegExMatch(Option, "\bv\S*", &match) ? match[] : ""
            }
        }

        UpdateGifPath(CurrCtl, Value) {
            CurrCtl.Gif.doc.getElementById("Gif").src := Value
        }
    }
}
;///////////////////////////////////////////////////////////////////////////////////////////
