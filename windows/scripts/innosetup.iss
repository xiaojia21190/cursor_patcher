[Setup]
AppName=cusor_patcher
AppVersion={#AppVersion}
AppPublisher=Xmarmalade
AppCopyright=Copyright (C) 2023 Xmarmalade
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
DefaultDirName={autopf}\cusor_patcher\
DefaultGroupName=cusor_patcher
SetupIconFile=cusor_patcher.ico
UninstallDisplayIcon={app}\cusor_patcher.exe
UninstallDisplayName=cusor_patcher
UsePreviousAppDir=no
PrivilegesRequiredOverridesAllowed=dialog
PrivilegesRequired=lowest
CloseApplications=yes


[Messages]
ConfirmUninstall=Are you sure you want to completely remove %1 and all of its components?%nIMPORTANT NOTE: Please quit %1 before clicking Yes!
ApplicationsFound=The following applications are using files that need to be updated by Setup. It is recommended that you allow Setup to automatically close these applications.%nIMPORTANT NOTE: If you allow cusor_patcher to minimize to tray, you need to exit cusor_patcher manually!
ApplicationsFound2=The following applications are using files that need to be updated by Setup. It is recommended that you allow Setup to automatically close these applications.%nIMPORTANT NOTE: If you allow cusor_patcher to minimize to tray, you need to exit cusor_patcher manually!

[Files]
Source: "Release\cusor_patcher.exe"; DestDir: "{app}"; DestName: "cusor_patcher.exe"
Source: "Release\*"; DestDir: "{app}"
Source: "Release\data\*"; DestDir: "{app}\data\"; Flags: recursesubdirs

[Icons]
Name: "{userdesktop}\cusor_patcher"; Filename: "{app}\cusor_patcher.exe"
Name: "{group}\cusor_patcher"; Filename: "{app}\cusor_patcher.exe"
