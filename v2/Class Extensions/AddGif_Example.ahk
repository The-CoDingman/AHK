#Requires AutoHotkey v2+        ;Forces the interpreter to use AHK v2
#SingleInstance Force           ;Only allow once instance of the script at a time
#Include Class_Extensions.ahk   ;Include the Class Extension library

MyGui := Gui()
MyGif := MyGui.AddGif("w480 h480 vExampleGif", A_ScriptDir "\Example_Gif_1.gif")
MyGui.Show("Center")

F1:: {
    MyGui["ExampleGif"].Visible := !MyGui["ExampleGif"].Visible ;Using the vName to affect the control
}

F2:: {
    MyGif.Visible := !MyGif.Visible ;Using a variable to affect the control
}

F3:: {
    MyGif.Value := "New Text Value" ;Not recommended to do this, it will cause flickering and may cause other issues
}

F4:: {
    MyGif.UpdateGif(A_ScriptDir "\Example_Gif_2.gif") ;How to change the image being displayed
}