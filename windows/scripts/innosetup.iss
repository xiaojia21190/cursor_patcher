[Setup]
AppName=cursor_patcher
AppVersion={#AppVersion}
AppPublisher=Xmarmalade
AppCopyright=Copyright (C) 2023 Xmarmalade
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
DefaultDirName={autopf}\cursor_patcher\
DefaultGroupName=cursor_patcher
SetupIconFile=cursor_patcher.ico
UninstallDisplayIcon={app}\cursor_patcher.exe
UninstallDisplayName=cursor_patcher
UsePreviousAppDir=no
PrivilegesRequiredOverridesAllowed=dialog
PrivilegesRequired=lowest
CloseApplications=yes


[Messages]
ConfirmUninstall=Are you sure you want to completely remove %1 and all of its components?%nIMPORTANT NOTE: Please quit %1 before clicking Yes!
ApplicationsFound=The following applications are using files that need to be updated by Setup. It is recommended that you allow Setup to automatically close these applications.%nIMPORTANT NOTE: If you allow cursor_patcher to minimize to tray, you need to exit cursor_patcher manually!
ApplicationsFound2=The following applications are using files that need to be updated by Setup. It is recommended that you allow Setup to automatically close these applications.%nIMPORTANT NOTE: If you allow cursor_patcher to minimize to tray, you need to exit cursor_patcher manually!

[Files]
Source: "Release\cursor_patcher.exe"; DestDir: "{app}"; DestName: "cursor_patcher.exe"
Source: "Release\*"; DestDir: "{app}"
Source: "Release\data\*"; DestDir: "{app}\data\"; Flags: recursesubdirs

[Icons]
Name: "{userdesktop}\cursor_patcher"; Filename: "{app}\cursor_patcher.exe"
Name: "{group}\cursor_patcher"; Filename: "{app}\cursor_patcher.exe"
