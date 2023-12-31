;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;Function:      Loops through a designated directory and generates code and/or an #Include file with conditional checks
;Versioning:    Credits: Panaku (The CoDingman) | AHK Version: v2.0 | Script Version: 1.0/09-28-23
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;This software is provided 'as-is', without any express or implied warranty.
;In no event will the authors be held liable for any damages arising from the use of this software.
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;Environment Controls
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#Requires Autohotkey v2.0
#SingleInstance Force
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;Create GUI
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
FileInstallGui := Gui("", "FileInstall Automator")
DestinationDirText := FileInstallGui.Add("Text", "xm cNavy", "Please enter your destination path: ")
DestinationDirEdit := FileInstallGui.Add("Edit", "w460", "A_Desktop `"\Example`"")
FileMaskText := FileInstallGui.Add("Text", "xm y+10 cNavy", "Please enter the desired `"File Mask`": ")
FileMaskEdit := FileInstallGui.Add("Edit", "w460", "*.*")
CreateIncludeFileCheckbox := FileInstallGui.Add("CheckBox", "y+15", "Create an `"#Include`" file?")
OverwriteFilesCheckbox := FileInstallGui.Add("CheckBox", "x+10", "Overwrite existing files?")
CreateIncludeFileEdit := FileInstallGui.Add("Edit", "xm w460 +ReadOnly", "<#Include File Path>")
SelectSourceDirButton := FileInstallGui.Add("Button", "xm+360 w100", "Generate List")
SelectSourceDirButton.OnEvent("Click", (*) => CreateFileInstall(StrReplace(DestinationDirEdit.Value, "`'", "`"")))
FileInstallCodeEdit := FileInstallGui.Add("Edit", "xm w460 h400 Hidden", "")
CopyCodeButton := FileInstallGui.Add("Button", "xm+310 w150 Hidden", "Copy Code to Clipboard")
CopyCodebutton.OnEvent("Click", (*) => A_Clipboard := FileInstallCodeEdit.Value)
StatusBar := FileInstallGui.Add("StatusBar",, "*")
StatusBar.SetParts(140, 160, 180)
StatusBar.SetText("List Generation: Unstarted", 1), StatusBar.SetText("Files Accounted For: ", 2), StatusBar.SetText("Directories Accounted For: ", 3)
FileInstallGui.Show("AutoSize")
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;Code Generation Functions
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CreateFileInstall(Destination) {
    if (FileMaskEdit.Value = "") {
        MsgBox("Please enter a valid `"File Mask`"", "Error", "262144")
        return
    }
    SelectedDir := DirSelect("::{20D04FE0-3AEA-1069-A2D8-08002B30309D}", 3, "Please select the Directory you want to parse")
    if (SelectedDir = "") {
        StatusBar.SetText("List Generation: Canceled", 1)
        return
    }
    if (CopyCodeButton.Visible = 1) {
        CopyCodeButton.Visible := FileInstallCodeEdit.Visible := 0
        StatusBar.SetText("List Generation: Unstarted", 1), StatusBar.SetText("Files Accounted For: ", 2), StatusBar.SetText("Directories Accounted For: ", 3)
        FileInstallGui.Show("AutoSize")
    }
    FileInstallDirArray := []
    IncludeFileCheckboxStatus := CreateIncludeFileCheckBox.Value
    OverwriteFilesCheckboxStatus := OverwriteFilesCheckbox.Value
    SplitPath(SelectedDir, &OutFileName, &OutDir, &OutExtension, &OutNameNoExt, &OutDrive)
    FileInstallDirArray.Push(OutFileName)
    FileInstallOutput := ";Create Destination Directory if needed`nif (!DirExist(" Destination ")) {`n`tDirCreate(" Destination ")`n}"
    Destination := RegExMatch(Destination, "(`"|`')$", &FoundMatch) ? RTrim(Destination, FoundMatch[]) : Destination " `""
    Loop Files, SelectedDir "\*", "D" {
        FileInstallDirArray.Push(OutFileName "\" StrReplace(A_LoopFileFullPath, SelectedDir "\", ""))
        RecurseFolders(A_LoopFileFullPath, OutFileName "\" StrReplace(A_LoopFileFullPath, SelectedDir "\", ""), FileInstallDirArray)
    }

    FileCount := DirectoryCount := 0
    Loop Files, SelectedDir "\*", "DR" {
        FileMaskFound := FileMaskCheck(OutDir "\" FileInstallDirArray[A_Index], FileMaskEdit.Value)
        if (FileMaskFound = 1) {
            DirectoryCount += 1
            FileInstallOutput .= "`n`n;Create `"\" FileInstallDirArray[A_Index] "`" Directory if needed and ``FileInstall`` nested files if needed`nif (!DirExist(" Destination "\" FileInstallDirArray[A_Index] "`")) {`n`tDirCreate(" Destination "\" FileInstallDirArray[A_Index] "`")`n}"
            Loop Files, OutDir "\" FileInstallDirArray[A_Index] "\" FileMaskEdit.Value {
                FileCount += 1
                if (OverwriteFilesCheckboxStatus = 0) {
                    FileInstallOutput .= "`nif (!FileExist(" StrReplace(A_LoopFileFullPath, SelectedDir, Destination "\" OutFileName) "`")) {`n`t"
                    FileInstallOutput .= "FileInstall(`"" A_LoopFileFullPath "`", " StrReplace(A_LoopFileFullPath, SelectedDir, Destination "\" OutFileName) "`", false)`n}"
                }
                else {
                    FileInstallOutput .= "`nFileInstall(`"" A_LoopFileFullPath "`", " StrReplace(A_LoopFileFullPath, SelectedDir, Destination "\" OutFileName) "`", true)"
                }
            }
        }
    }
    
    CopyCodeButton.Visible := FileInstallCodeEdit.Visible := 1
    FileInstallCodeEdit.Value := Trim(Trim(FileInstallOutput, "`n"))
    StatusBar.SetText("List Generation: Complete", 1), StatusBar.SetText("Files Accounted For: " FileCount, 2), StatusBar.SetText("Directories Accounted For: " DirectoryCount, 3)
    if (IncludeFileCheckboxStatus = 1) {
        try {
            IncludeFile := FileOpen("FileInstall -- " OutFileName ".ahk", "w")
		    IncludeFile.Write(FileInstallOutput)
		    IncludeFile.Close()
            CreateIncludeFileEdit.Value := A_ScriptDir "\FileInstall -- " OutFileName "_directory.ahk"
        }
        catch {
            MsgBox("Error Creating `"#Include`" File", "Error", "262144")
        }
    }
    else {
        CreateIncludeFileEdit.Value := "<#Include File Path>"
    }
    CopyCodeButton.Visible := FileInstallCodeEdit.Visible := 1
    FileInstallGui.Show("AutoSize")
}

FileMaskCheck(Directory, FileMask, MaskFound := 0) {
    Loop Files, Directory "\" FileMask, "FR" {
        MaskFound := 1
    }
    return MaskFound
}

RecurseFolders(Dir, Parent, DirectoryArray) {
	Loop Files, Dir "\*", "D" {
		DirectoryArray.Push(Parent "\" A_LoopFileName)
		RecurseFolders(Dir "\" A_LoopFileName, Parent "\" A_LoopFileName, DirectoryArray)
	}
}
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
