unit miproc;
interface

uses
  SysUtils,
  DvCrt,
  DvForm,
  DvWin,
  DvArq,
  mimsg,
  miplaylist,
  mivars,
  miparam,
  classes,
  miplayer;

procedure procuraArquivoMultimidia;
procedure procuraPlayList;
procedure selecionaDiretorio;


implementation

{-------------------------------------------------------------}
{                           Acerta nome
{-------------------------------------------------------------}

function acertaNome (nomeArq: string): string;
begin
    acertaNome := '';
    nomeArq := trim (nomeArq);
    if nomeArq = '' then exit;

    if pos (' ', nomeArq) <> 0 then
        nomeArq := '"' + nomeArq + '"';

    acertaNome := nomeArq;
end;

{--------------------------------------------------------}
{          Procura um arquivo multimidia específico
{--------------------------------------------------------}

procedure procuraArquivoMultimidia;
var
    nomeMidia, nome: String;
    i:integer;
    listMidias: TList;
    psr: ^TMySearchRec;
    ext: string;
    marcados: integer;

begin
    mensagem('MINARQMM',1);     {'Informe o nome do arquivo multimídia:'}
    listArqPersistente := true;
    nomeMidia := obtemNomeArqMasc (25-wherey, '*.wav|*.mp4|*.mp3|*.aac|*.AU|*.mid|*.rm|*.ogg|*.aiff|*.wmv|*.mpeg|*.rmvb|*.avi|*.3gp|*.MOV|*.FLV');

    ext := ExtractFileExt(nomeMidia);
    if (nomeMidia = '') or (ext = '')then
        begin
            writeln;
            mensagem ('MIMMNENC', 1);   { 'Nenhum arquivo multimídia foi selecionado.' }
            exit;
        end
    else
        begin
            listMidias := obtemListArq;
            if listMidias = NIL then listMidias := TList.Create;
            marcados := 0;
            for i := 0 to listMidias.count-1 do
                begin
                    psr := listMidias[i];
                    if psr^.marcado then
                        begin
                             marcados := marcados +1;
                             nome := psr^.sr.Name;
                             playlist.add(nome);
                        end;
                end;
            liberaListArq;
            if (marcados = 0) then
                playlist.Add (nomeMidia);
        end;

    limpabaixo(1);
    folheiaPlaylist;
end;

{--------------------------------------------------------}
{                    Procura um arquivo m3u
{--------------------------------------------------------}

procedure procuraPlayList;
var
    nomeArq: String;
    ext: string;

begin
    mensagem ('MINARQLR', 0);     {'Informe o nome do arquivo .M3U:'}
    nomeArq := obtemNomeArqMasc (25-wherey, '*.m3u');

    ext := uppercase(ExtractFileExt(nomeArq));
    if (nomeArq = '') or (ext <> '.M3U') then
        begin
            writeln;
            mensagem ('MIM3UNEC', 0);   { 'Nenhum arquivo .M3U foi selecionado.' }
            exit;
        end
    else
        begin
            if abrePlayList(acertaNome (nomeArq)) then
                begin
                    limpabaixo(1);
                    folheiaPlaylist;
                end
            else
                exit;
        end;
end;

{--------------------------------------------------------}
{    Executa arquivos de multimidia de um diretório
{--------------------------------------------------------}

procedure selecionaDiretorio;
var
    dir__:string;
    c: char;
    ypos: integer;
begin
    ypos := wherey;
    while true do
        begin
            limpabaixo(ypos);

            dir__ := '';
            mensagem('MINMEDIR',1); {'Informe o diretório e tecle Enter: ' }
            c := sintEdita(dir__, wherex, wherey, 255, true);
            if (c = BAIX) or (c = CIMA) then
                continue;

            if c = ESC then
                begin
                    mensagem('MIDESIST',2);  { 'Desistiu...'  }
                    exit;
                end;

            if not DirectoryExists(dir__) then
                begin
                    limpabaixo(wherey);
                    mensagem('MIDIRNFE',1);   {'O diretório não existe.'  }
                end;
            if DirectoryExists(dir__) then
                break;
        end;

    varreDiretorio(dir__);
    limpabaixo(1);    
    folheiaPlaylist;
    
end;

end.


