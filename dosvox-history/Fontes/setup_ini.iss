; REINSTALADOR DO DOSVOX.INI
; POR: ANTONIO BORGES
; EM SETEMBRO DE 2012


[Setup]
AppVersion=1.0
AppName=dosvox.ini
DefaultDirName=C:\winvox
DisableDirPage=yes
DefaultGroupName=Dosvox para Windows
DisableProgramGroupPage=yes
DisableReadyPage=yes
OutputDir=c:\wv44
OutputBaseFilename=dosvox-ini-setup
Compression=lzma
SolidCompression=yes

[Languages]
Name: PTB; MessagesFile: compiler:Languages\BrazilianPortuguese.isl

[Files]
Source: c:\wv\dosvox.ini; DestDir: {win}; Permissions: users-modify

[UninstallDelete]
Type: filesandordirs; name: {app}
