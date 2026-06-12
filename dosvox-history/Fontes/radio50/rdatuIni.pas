{--------------------------------------------------------}
{                                                        }
{    Radio50 - Executor interativo de streams de áudio   }
{                                                        }
{    Atualização das rádios                              }
{                                                        }
{    Autor:  José Antonio Borges                         }
{                                                        }
{    Em outubro/2015                                     }
{                                                        }
{--------------------------------------------------------}

unit rdatuIni;

interface
uses
    dvcrt,
    dvwin,
    dvForm,
    dvArq,
    dvAmplia,
    dvInet,
    sysUtils,
    classes,
    rdmsg,
    rdvars;

procedure atualizarIni;

implementation
var
    preferidasAntigas: TStringList;

{--------------------------------------------------------}
{           faz download do arquivo radio50.ini
{--------------------------------------------------------}

function downloadText (servidor, loc, nomeArq: string): boolean;
const
    UM_K = 1024;

var
    sock : integer;
    buf : pbufrede;
    arq : textFile;
    s: string;
    status: string;
    codret, erroVal: integer;

label montacabec, fim, fimRede;

begin
    result := false;
    assignfile(arq, nomearq);

    sock := abreConexaoSsl(servidor, 443);
    if sock <= 0 then
        exit;
    writelnRede(sock,'GET '+ loc +' HTTP/1.0');
    writelnRede(sock,'Host: ' + servidor);
    writelnRede(sock,'');

    buf := inicBufRede(sock);
    readlnBufRede(buf, s, 0);
    writeln (s);
    status := copy (s, pos(' ', s) + 1, 3);
    val (status, codret, erroVal);
    if erroVal <> 0 then codRet := 404;
    if codret <> 200 then
        exit;

    {$I-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        begin
            mensagem ('RDERRWAR', 1);  {'Erro de escrita no arquivo.'}
            exit;
         end;

    repeat
        if not readlnBufRede(buf, s, 0) then break;
    until s = '';

    sintClek;
    repeat
        if not readlnBufRede(buf, s, 0) then break;
        writeln (arq, s);
    until false;
    closefile(arq);
    sintClek;

fimRede:
    fimbufrede(buf);
    fechaconexao(sock);
    result := true;
end;

{--------------------------------------------------------}
{                atualiza INI pela Internet
{--------------------------------------------------------}

procedure atualizaPorInternet;
var
    nomeArq: string;
    p: integer;
    siteAtualiza: string;
    servidor, loc: string;
begin
    siteAtualiza := sintAmbiente ('RADIO50', 'SITEATUALIZA', 'https://intervox.nce.ufrj.br/~amuniz/radio50.ini');

    p := pos('//', siteAtualiza);
    if p <> 0 then
        delete (siteAtualiza, 1, p+1);
    p := pos ('/', siteAtualiza);
    servidor := copy (siteAtualiza, 1, p-1);
    loc := copy (siteAtualiza, p, length(siteAtualiza));
    nomeArq := arqIndice + '.tmp';

    if not downloadText (servidor, loc, nomeArq) then
        begin
            mensagem ('RDATNENC', 2);   {'Arquivo de atualização não foi achado na internet'}
            mensagem ('RDAPTENT', 1);   {'Aperte enter'}
            readln;
            exit;
        end;

    deleteFile (arqIndice);
    renameFile (nomeArq, arqIndice);
end;

{--------------------------------------------------------}
{            testa se a chave da rádio existe
{--------------------------------------------------------}

function existeChave (categoria, item: string): boolean;
begin
    existeChave := sintAmbienteArq (categoria, item, '', arqIndice) <> '';
end;

{--------------------------------------------------------}
{               grava a chave da rádio
{--------------------------------------------------------}

procedure gravaChave (categoria, s: string; realtera: boolean; var totalChavesInvalidas: integer);
var
    item, valor: string;
    p: integer;
begin
    p := pos ('=', s);
    if p = 0 then
        begin
            if sintFalarTudo then
                begin
                    mensagem ('RDCHINVA', 1); {'Chave inválida'}
                    sintWriteln (s);
//                    mensagem ('RDAPTENT', 0);
//                    readln;
                end
            else
                sintClek;

            inc (totalChavesInvalidas);
            sintGravaAmbienteArq ('CHAVES_INVALIDAS_EM_' + formatdatetime('DD/MM/YYYY',now), s, categoria, sintDirAmbiente + '\Radio50.log');
        end
    else
        begin
            item := copy (s, 1, p-1);
            valor := copy (s, p+1, length(s));

            if trim(valor) = '' then   // remoções forçadas mesmo existentes
                sintRemoveAmbienteArq(categoria, item, arqIndice)
            else
                if realtera or (not existeChave (categoria, item)) then
                    sintGravaAmbienteArq (categoria, item, valor, arqIndice);
        end;
end;

{--------------------------------------------------------}
{         atualiza INI a partir de um arquivo
{--------------------------------------------------------}

procedure atualizaPorArquivo;
var
    c, c2: char;
    realtera: boolean;
    categoria, s: string;
    ls_arq: TStringList;
    nomeArq: string;
    totalChavesInvalidas, i: integer;

begin
    mensagem ('RDARQMUD', 1);  {'Informe o nome do arquivo que contém as mudanças'}
    nomeArq := obtemNomeArq (5);
    writeln;
    if nomeArq = '' then exit;

    ls_arq := TStringList.Create;
    try
        ls_arq.LoadFromFile (nomeArq);
    except
        mensagem ('RDARQNEX', 2);  {'Arquivo não existe'}
        ls_arq.Free;
        exit;
    end;

    mensagem ('RDMODIFA', 0);  {'Deseja modificar itens anteriormente criados?'}
    sintLeTecla (c, c2);
    writeln;
    if c = ESC then
        begin
            ls_arq.Free;
            exit;
        end;
    realtera := upcase (c) = 'S';

//  deleteFile (sintDirAmbiente + '\Radio50.log');
    totalChavesInvalidas := 0;
    categoria := '';
    for i := 0 to (ls_arq.Count - 1) do
        begin
            s := ls_arq[i];
            if (s <> '') and (s[1] <> ';') and (s[1] <> '*') then
                begin
                    if s[1] = '[' then
                        begin
                            delete (s, 1, 1);
                            delete (s, length(s), 1);
                            categoria := s;
                            writeln (categoria);
                        end
                    else
                        gravaChave (categoria, s, realtera, totalChavesInvalidas);
                end;
        end;

    ls_arq.Free;

    limpaBufTec;
    if totalChavesInvalidas > 0 then
        begin
            sintGravaAmbienteArq ('CHAVES_INVALIDAS_EM_' + formatdatetime('DD/MM/YYYY',now), 'Total de chaves inválidas', intToStr(totalChavesInvalidas), sintDirAmbiente + '\Radio50.log');
            mensagem ('RDTOTCHINVA', 0); {'Total de chaves inválidas: '}
            sintWriteInt (totalChavesInvalidas); writeln;
        end;

    mensagem ('RDOK', 2);        {'Ok'}
end;

{--------------------------------------------------------}
{            tratamento das rádios preferidas
{--------------------------------------------------------}

function backupPreferidas: boolean;
var
    c: char;
    i: integer;
begin
    mensagem ('RDMANPRF', 0); {'Deseja manter suas rádios preferidas? '}
    c := popupMenuPorLetra('SN');
    if c = ESC then result := false
    else
        begin
            result := true;
            preferidasAntigas := TStringList.Create;
            if c = 'S' then
                for i := 1 to MAXPREFERIDAS do
                    preferidasAntigas.add (
                        sintAmbienteArq ('PREFERIDAS', intToStr(i), '', arqIndice));
        end;
end;

{--------------------------------------------------------}

procedure regravaPreferidas;
var i: integer;
begin
    if preferidasAntigas.Count <> 0 then
        for i := 1 to MAXPREFERIDAS do
            sintGravaAmbienteArq('PREFERIDAS', intToStr(i), preferidasAntigas[i-1], arqIndice);

    preferidasAntigas.Free;
end;

{--------------------------------------------------------}
{            atualiza os registros das rádios
{--------------------------------------------------------}

procedure atualizarIni;
var c: char;
begin
    if not backupPreferidas then exit;

    mensagem ('RDATUINT', 0);  {'Quer atualizar pela Internet? '}
    c := popupMenuPorLetra('SN');
    if c = ESC then
        exit
    else
    if c <> 'N' then
        atualizaPorInternet
    else
        atualizaPorArquivo;

    regravaPreferidas;
end;

{--------------------------------------------------------}

begin
end.
