; INSTALADOR DO DOSVOX VERSÃO 6.3 mini X86
; Original pOR: CLEVERSON CASARIN ULIANA
; MODIFICADO POR: NENO ALBERNAZ
; EM MARÇO DE 2025 - Geração da versão 6.3 do Dosvox mini.

#define Nome "Dosvox"
#define NomeVer "Dosvox mini Versão 6.3"
#define PublicadoPor "Instituto Tércio Pacitti - NCE/UFRJ"
#define Pagina "http://intervox.nce.ufrj.br/dosvox"
#define Exec "dosvox.exe"
#define Link "webvox.exe http://intervox.nce.ufrj.br/dosvox"
#define Atual "http://intervox.nce.ufrj.br/update"

[Setup]
AppName={#Nome}
AppVerName={#NomeVer}
AppPublisher={#PublicadoPor}
AppPublisherURL={#Pagina}
AppSupportURL={#Pagina}
AppUpdatesURL={#Atual}
DefaultDirName=C:\Winvox
DisableDirPage=no
DefaultGroupName=Dosvox para Windows
DisableProgramGroupPage=yes
DisableReadyPage=yes
OutputDir=\DV_Setup
OutputBaseFilename=dv63-mini-setup-X86
;Compression=lzma
Compression=lzma2/ultra64
SolidCompression=yes

[Languages]
Name: PTB; MessagesFile: compiler:Languages\BrazilianPortuguese.isl

[Files]
Source: \wv_win\*; DestDir: {win}; Flags: recursesubdirs createallsubdirs onlyifdoesntexist
Source: \wv_mini\*; DestDir: {app}; Flags: recursesubdirs createallsubdirs
Source: \wv_exter_mini\*; DestDir: {app}; Flags: recursesubdirs createallsubdirs

Source: \wv\iniOriginal\provedor.ini; DestDir: {userappdata}\Dosvox; Flags: recursesubdirs createallsubdirs

[Icons]
Name: {userdesktop}\{#nome}; Filename: {app}\{#Exec}; WorkingDir: {app}
Name: {group}\{#Nome}; Filename: {app}\{#Exec}; WorkingDir: {app}; HotKey: ctrl+alt+d
Name: "{group}\Manual Interativo do Dosvox"; Filename: {app}\manvox.exe; WorkingDir: {app}
Name: "{group}\Manual Básico do Dosvox"; Filename: {app}\Manual\Dosvox.txt; WorkingDir: {app}\Manual
Name: "{group}\Leitor de Telas Monitvox"; Filename: {app}\monit32.exe; WorkingDir: {app}; HotKey: ctrl+alt+m
Name: "{group}\Manual do Monitvox"; Filename: {app}\Manual\monit32.txt; WorkingDir: {app}\Manual
Name: {group}\{cm:ProgramOnTheWeb,{#Nome}}; Filename: {app}\{#Link}
Name: {group}\{cm:UninstallProgram,{#Nome}}; Filename: {uninstallexe}

[UninstallDelete]
Type: filesandordirs; name: {app}

[Run]
;Filename: {app}\instaladores\LAVFilters-0.67-Installer.exe
;Filename: {app}\instaladores\spchapi.exe; Description: "Instalar fala SAPI"; StatusMSG: "Configurando SAPI 4.0..."
;Filename: {app}\instaladores\lhttsptb.exe; Description: "Instalar sintetizador SAPI em Português"
Filename: {app}\{#Exec}; Description: {cm:LaunchProgram,{#Nome}}; Flags: nowait skipifsilent
