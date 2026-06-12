; INSTALADOR PARA O JOGAVOX STANDALONE
; POR: ANTONIO BORGES
; EM JUNHO DE 2016

#define Nome "Jogavox"
#define NomeVer "Jogavox Versão 3.0"
#define PublicadoPor "Instituto Tércio Pacitti - NCE/UFRJ"
#define Pagina "http://intervox.nce.ufrj.br/jogavox"
#define Exec "jogavox.exe"
#define Link "http://intervox.nce.ufrj.br/jogavox"
#define Atual "http://intervox.nce.ufrj.br/update"

[Setup]
AppName={#Nome}
AppVerName={#NomeVer}
AppPublisher={#PublicadoPor}
AppPublisherURL={#Pagina}
AppSupportURL={#Pagina}
AppUpdatesURL={#Atual}
DefaultDirName=C:\winvox
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
Source: c:\wv\fontes\jogavox\*.*; DestDir: {app}\fontes\jogavox; Flags: recursesubdirs createallsubdirs
Source: c:\wv\som\jogavox\*.*; DestDir: {app}\som\jogavox; Flags: recursesubdirs createallsubdirs
Source: c:\wv\som\difones\*.*; DestDir: {app}\som\difones; Flags: recursesubdirs createallsubdirs
Source: c:\wv\som\letras\*.*; DestDir: {app}\som\letras; Flags: recursesubdirs createallsubdirs
Source: c:\wv\lianetts\*.*; DestDir: {app}\lianetts; Flags: recursesubdirs createallsubdirs
;Source: c:\wv\instaladores\mbrola*.*; DestDir: {app}; Flags: recursesubdirs createallsubdirs
Source: c:\wv\iniOriginal\dosvox.ini; DestDir: {userappdata}\Dosvox; Flags: recursesubdirs createallsubdirs

[Icons]
Name: {userdesktop}\{#nome}; Filename: {app}\{#Exec}; WorkingDir: {app}
Name: {group}\{#Nome}; Filename: {app}\{#Exec}; WorkingDir: {app}

[UninstallDelete]
Type: filesandordirs; name: {app}

[Run]
;Filename: {app}\mbrola35.exe; Description: "Instalar sistema Mbrola"
Filename: {app}\{#Exec}; Description: {cm:LaunchProgram,{#Nome}}; Flags: nowait skipifsilent
