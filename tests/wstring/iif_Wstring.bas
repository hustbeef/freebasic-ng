Dim As WString FolderName, ExeFileName, ExeFileName111 = "abc.exe"
ExeFileName = IIf(FolderName = "", "/Projects/" , FolderName) & ExeFileName111
Print ExeFileName