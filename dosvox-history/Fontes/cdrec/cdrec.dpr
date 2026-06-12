{ Gravador de CD experimental usando IMAP2 }
{ Por José Antonio Borges }
{ Em 18/1/2011 }

program cdrec;
uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, OleServer, IMAPI2_TLB, IMAPI2FS_TLB, ComCtrls, ShellApi,
    dvcrt, dvwin;

var
    MsftDiscMaster: TMsftDiscMaster2;
    MsftDiscRecorder: TMsftDiscRecorder2;
    MsftFileSystemImage: TMsftFileSystemImage;
    MsftDiscFormat2Data: TMsftDiscFormat2Data;

    DiscVolumeName: string;
    FilesList: TStringList;
    indGrav: integer;
    nomeDir: string;

var
  wstr:WideString;
  i:integer;
  DiscRoot:IFsiDirectoryItem;
  resimage:IFileSystemImageResult;
  DiscStream,fstream:IMAPI2_TLB.IStream;
  DR:IDiscRecorder2;

Function SHCreateStreamOnFileEx(
     pszFile: PWChar;
     grfMode:DWORD;
     dwAttributes:DWORD;
     fCreate:BOOL;
     pstmTemplate:IStream;
     var ppstm:IStream): DWORD;stdcall;
          external 'shlwapi.dll' name 'SHCreateStreamOnFileEx';

procedure aborta (m: string);
begin
    sintWriteln (m);
    sintFim;
    doneWinCrt;
end;

function geraFilesList(nomeDir: string): boolean;
var
    sr: TSearchRec;
    dir: string;
    ndir, narq: integer;
begin
    ndir := 0;
    narq := 0;
    getdir (0, dir);
    {$I-} chdir (nomeDir); {$I+}
    if ioresult <> 0 then
        begin
            sintWriteln ('Erro no diretório');
            result := false;
            exit;
        end;

    filesList := TStringList.Create;
    if findFirst ('*.*', faDirectory + faArchive, sr) = 0 then
        repeat
             if (sr.name = '.') or (sr.Name = '..') then
                 continue;
             filesList.add (sr.name);
             if (sr.Attr and faDirectory) <> 0 then
                 ndir := ndir + 1
             else
                 narq := narq + 1;
        until findNext (sr) <> 0;

    sintWriteln (intToStr(narq) + ' arquivos, ' + intToStr(ndir) + ' diretórios');
    result := true;
end;

begin
    sintInic (0, '');
    sintWriteln ('Mini Gravador de CD para Windows 7');

    sintWriteln ('Nome do CD (12 letras): ');
    sintReadln (DiscVolumeName);
    sintWriteln ('Nome do diretório a gravar');
    sintReadln (nomeDir);
    if not geraFilesList(nomeDir) then
        begin
            sintFim;
            doneWinCrt;
        end;
    sintWriteln ('Insira o CD e aperte Enter quando pronto');
    readln;

    MsftDiscMaster := TMsftDiscMaster2.Create(NIL);
    MsftDiscRecorder := TMsftDiscRecorder2.Create(NIL);
    MsftFileSystemImage := TMsftFileSystemImage.Create(NIL);
    MsftDiscFormat2Data := TMsftDiscFormat2Data.Create(NIL);

    if not MsftDiscMaster.IsSupportedEnvironment then
        aborta('Não há gravadores de CD instalados');

    for i := 0 to MsftDiscMaster.Count-1 do
       begin
           try
                MsftDiscRecorder.InitializeDiscRecorder(MsftDiscMaster.Item[i]);
                writeln (i, ' ', MsftDiscRecorder.VendorId+' '+MsftDiscRecorder.ProductId);
                MsftDiscRecorder.Disconnect;
           except
                writeln (i, ' não pode gravar');
           end;
      end;

    if MsftDiscMaster.Count = 1 then
        indGrav := 0
    else
        begin
            sintWriteln ('Gravador a usar, entre 0 e ' +
                         intToStr(MsftDiscMaster.Count-1) + ' : ');
            sintReadint (indGrav);
        end;

    MsftDiscRecorder.InitializeDiscRecorder(MsftDiscMaster.Item[indGrav]);
    DiscRoot:=(MsftFileSystemImage.Root) as IFsiDirectoryItem;

    MsftDiscFormat2Data.Recorder:=MsftDiscRecorder.DefaultInterface;
    MsftDiscFormat2Data.ClientName:='IMAPI';

    DR:=IDiscRecorder2(MsftDiscRecorder.DefaultInterface);
    MsftFileSystemImage.ChooseImageDefaults(DR);
    MsftFileSystemImage.VolumeName:= DiscVolumeName;

    sintWriteln('Preparando a gravação, aguarde');
    for i:=0 to FilesList.Count-1 do
       begin
          if DirectoryExists(FilesList[i]) then
             DiscRoot.AddTree(FilesList[i],true);
          if FileExists(FilesList[i])  then
             begin
                 wstr := FilesList[i];
                 SHCreateStreamOnFileEx(PWideChar(wstr),0,0,False,nil,IStream(fstream));
                 DiscRoot.AddFile(ExtractFileName(FilesList[i]),
                                  IMAPI2FS_TLB.IStream(fstream));
             end;
       end;

    resimage:=MsftFileSystemImage.CreateResultImage;
    DiscStream:=IMAPI2_TLB.IStream(resimage.ImageStream);

    sintWriteln('Gravação iniciada');
    try
        MsftDiscFormat2Data.Write(DiscStream);
        MsftDiscRecorder.EjectMedia;
        sintWriteln ('Gravação terminada');
    except
        sintWriteln('Erro de gravação');
    end;

    MsftDiscRecorder.Disconnect;
    sintFim;
    doneWinCrt;
end.
