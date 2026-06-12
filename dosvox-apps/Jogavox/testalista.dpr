program testeLista;

uses
dvcrt,
dvwin,
dvInet,
dvDownload,
dvArqLog,
windows,
classes,
sysUtils;

const
dirBaseJogos='.';

function baixaHtml(url: string; listaHtml: TStringList): boolean;
var
    arqTemp: string;
begin
    result := true;
    abreWinSock;
    arqTemp := dirBaseJogos+'\jogos.$$$';
    if download (url, arqTemp, 0) <> DNWL_OK then
        begin
//            mensagem('JOBAERRO', 1); //'Erro ao tentar baixar o Jogo.'
            sintWriteln('Erro de download');
            result := false;
            exit;
        end;
    listaHtml.loadFromFile(arqTemp);
    deleteFile(arqTemp);
    fechaWinSock;
end;

function substitui(linha: string): string;
var i: integer;
begin
    for i := 1 to 7 do
        delete (linha, 1, pos('"', linha));
    delete (linha, pos('"', linha), 9999);
    linha := stringReplace(linha, '_', ' ', [rfReplaceAll, rfIgnoreCase]);
    linha := stringReplace(linha, '%20', ' ', [rfReplaceAll, rfIgnoreCase]);
    linha := stringReplace(linha, '%c3%a9', 'é', [rfReplaceAll, rfIgnoreCase]);
    // faltou trocar os outros acentos
    result := linha;
end;

procedure obterLista(dirDownload: string; lista: TStringList);
var
    listaDownload: TStringList;
    i: integer;
    linha: string;

begin
    listaDownload := TStringList.Create;
    baixaHtml(dirDownload, listaDownload);

    lista.Clear;
    for i := 11 to listaDownload.Count-5 do
         begin
             linha := substitui (listaDownload[i]);
             lista.add (linha);
         end;

    listaDownload.Free;
end;

var
    lista: TStringList;
    dirDownload: string;
    i: integer;
    aMostrar: string;

begin
    sintInic(0, '');
    lista := TStringList.Create;
    dirDownload := 'http://intervox.nce.ufrj.br/~projetojogavox/Site_Jogavox/Jogos/Gaia/';
    obterLista(dirDownload, lista);
    for i := 0 to lista.Count-1 do
        begin
            aMostrar := intToStr(i)+' '+lista[i];
            gravarArqLog(aMostrar, 'log.log');
        end;
    sintWriteln('ok');
    readln;
    lista.SaveToFile('lista.htm');
    lista.Free;
    sintFim;
end.
