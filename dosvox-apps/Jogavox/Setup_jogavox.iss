; INSTALADOR PARA O JOGAVOX STANDALONE
; POR: ANTONIO BORGES
; EM JUNHO DE 2016

[Setup]
AppName=Jogavox
AppVerName=Jogavox Versão 3.0
AppPublisher=Instituto Tércio Pacitti - NCE/UFRJ
AppPublisherURL=http://intervox.nce.ufrj.br/jogavox
AppSupportURL=antonio2@nce.ufrj.br
AppUpdatesURL=http://intervox.nce.ufrj.br/upgrade
DefaultDirName={pf}\Jogavox
DisableDirPage=no
DefaultGroupName=Dosvox para Windows
DisableProgramGroupPage=yes
DisableReadyPage=yes
OutputDir=c:\wv50
OutputBaseFilename=jogavox30-setup
Compression=lzma
SolidCompression=yes

[Languages]
Name: PTB; MessagesFile: compiler:Languages\BrazilianPortuguese.isl

[Files]
Source: c:\wv_dlls\*; DestDir: {sys}; Flags: recursesubdirs createallsubdirs
Source: c:\wv\jogavox.*; DestDir: {app}
Source: c:\wv\sapiutil.*; DestDir: {app}
Source: c:\wv\ajustaIni.*; DestDir: {app}

Source: c:\wv\jogavox\*.*; DestDir: {app}\jogavox; Flags: recursesubdirs createallsubdirs; Permissions: users-modify
Source: c:\wv\jogavox_modelos\*.*; DestDir: {app}\jogavox_modelos; Permissions: users-modify
Source: c:\wv\midias\*.*; DestDir: {app}\midias; Flags: recursesubdirs createallsubdirs; Permissions: users-modify
Source: c:\wv\som\jogavox\*.*; DestDir: {app}\som\jogavox; Flags: recursesubdirs createallsubdirs
Source: c:\wv\som\difones\*.*; DestDir: {app}\som\difones; Flags: recursesubdirs createallsubdirs
Source: c:\wv\som\letras\*.*; DestDir: {app}\som\letras; Flags: recursesubdirs createallsubdirs
Source: c:\wv\inioriginal\dosvox.ini; DestDir: {app}\inioriginal; Flags: recursesubdirs createallsubdirs
Source: c:\wv\lianetts\*.*; DestDir: {app}\lianetts; Flags: recursesubdirs createallsubdirs
Source: c:\wv\instaladores\mbrola*.*; DestDir: {app}; Flags: recursesubdirs createallsubdirs
Source: c:\wv\iniOriginal\dosvox.ini; DestDir: {userappdata}\Dosvox; Flags: recursesubdirs createallsubdirs
Source: c:\wv_win\unzip.exe; DestDir: {app}

[Icons]
Name: {userdesktop}\Jogavox; Filename: {app}\Jogavox.exe; WorkingDir: {app}
Name: {group}\Jogavox; Filename: {app}\Jogavox.exe; WorkingDir: {app}

[UninstallDelete]
Type: filesandordirs; name: {app}

[Registry]
Root: HKLM; Subkey: "Software\TCTS"
Root: HKLM; Subkey: "Software\TCTS\Mbrola"
Root: HKLM; Subkey: "Software\TCTS\Mbrola\databases"
Root: HKLM; Subkey: "Software\TCTS\Mbrola\databases\br4"
Root: HKLM; Subkey: "Software\TCTS\Mbrola\databases"; ValueType: string; ValueName: ""; ValueData: "br4"
Root: HKLM; Subkey: "Software\TCTS\Mbrola\databases\br4"; ValueType: string; ValueName:""; ValueData: "{app}\\lianetts\\br4"
Root: HKLM; Subkey: "Software\TCTS\Mbrola\databases\br4"; ValueType: string; ValueName:"Label"; ValueData: "br4"
Root: HKLM; Subkey: "Software\TCTS\Mbrola\databases\br4"; ValueType: string; ValueName:"DistantPath"; ValueData:""
Root: HKLM; Subkey: "Software\TCTS\Mbrola\databases\br4"; ValueType: string; ValueName:"New"; ValueData:"0"

[Run]
Filename: {app}\mbrola35.exe; Description: "Instalar sistema Mbrola"
Filename: {app}\ajustaIni.exe; Description: "Ajustar a Configuração"
Filename: {app}\Jogavox.exe; Description: {cm:LaunchProgram,Jogavox}; Flags: nowait skipifsilent
