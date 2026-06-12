; INSTALADOR DO DOSVOX de atualização
; Por Neno Henrique da Cunha Albernaz
; Em Abril de 2023

#define Nome "Dosvox"
#define NomeVer "Atualização Dosvox 6.1 para 6.3"
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
OutputBaseFilename=atualizacao_dv_61_para_63-setup
;Compression=lzma
Compression=lzma2/ultra64
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: PTB; MessagesFile: compiler:Languages\BrazilianPortuguese.isl

[Files]
Source: \wv_atualizacao\*; DestDir: {app}; Flags: recursesubdirs createallsubdirs
Source: \wv_exter\*; DestDir: {app}; Flags: recursesubdirs createallsubdirs
Source: \wv_exter32\*; DestDir: {app}; Flags: recursesubdirs createallsubdirs; Check: not Is64BitInstallMode
Source: \wv_exter64\*; DestDir: {app}; Flags: recursesubdirs createallsubdirs; Check: Is64BitInstallMode
Source: \wv_win\*; DestDir: {win}; Flags: recursesubdirs createallsubdirs onlyifdoesntexist

;Source: \wv\iniOriginal\radio50.ini; DestDir: {userappdata}\Dosvox; Flags: recursesubdirs createallsubdirs
;Source: \wv\iniOriginal\provedor.ini; DestDir: {userappdata}\Dosvox; Flags: recursesubdirs createallsubdirs
;Source: \wv\iniOriginal\voxnews.ini; DestDir: {userappdata}\Dosvox; Flags: recursesubdirs createallsubdirs

;[Icons]
;Name: {userdesktop}\{#nome}; Filename: {app}\{#Exec}; WorkingDir: {app}
;Name: {group}\{#Nome}; Filename: {app}\{#Exec}; WorkingDir: {app}; HotKey: ctrl+alt+d
;Name: "{group}\Manual Interativo do Dosvox"; Filename: {app}\manvox.exe; WorkingDir: {app}
;Name: "{group}\Manual Básico do Dosvox"; Filename: {app}\Manual\Dosvox.txt; WorkingDir: {app}\Manual
;Name: "{group}\Leitor de Telas Monitvox"; Filename: {app}\monit32.exe; WorkingDir: {app}; HotKey: ctrl+alt+m
;Name: "{group}\Manual do Monitvox"; Filename: {app}\Manual\monit32.txt; WorkingDir: {app}\Manual
;Name: {group}\{cm:ProgramOnTheWeb,{#Nome}}; Filename: {app}\{#Link}
;Name: {group}\{cm:UninstallProgram,{#Nome}}; Filename: {uninstallexe}

;[UninstallDelete]
;Type: filesandordirs; name: {app}

[Run]
;Filename: {app}\instaladores\LAVFilters-0.67-Installer.exe
;Filename: {app}\instaladores\spchapi.exe; Description: "Instalar fala SAPI"; StatusMSG: "Configurando SAPI 4.0..."
;Filename: {app}\instaladores\lhttsptb.exe; Description: "Instalar sintetizador SAPI em Português"
Filename: {app}\{#Exec}; Description: {cm:LaunchProgram,{#Nome}}; Flags: nowait skipifsilent
