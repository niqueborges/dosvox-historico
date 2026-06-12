{--------------------------------------------------------}

{
{    Tratamento Traduvox, chama o programa Traduvox por parãmetro
{
{    Autor: Neno Henrique da Cunha Albernaz
{
{    Em 22/08/2021
{
{--------------------------------------------------------}

Unit edTraduvox;

interface

uses
    DVWin, dvCrt, windows, sysUtils, classes,
    dvexec, dvForm,
    edDesfaz, EDLINHA, edVars, edUtil, edMensag;

procedure trataTraduvox (traduzDireto: boolean);

implementation


type
    TLingua = record
        cod, nome, som: string;
    end;

const
    TOTALCARACTERTRADUZ = 30000;
    maxLinguas = 7;
    linguas: array [1..maxLinguas] of Tlingua = (
        (cod:'en'; nome:'Inglês';    som:'EDINGLES'),
        (cod:'pt'; nome:'Português'; som:'EDPORTUG'),
        (cod:'es'; nome:'Espanhol';  som:'EDESPAN'),
        (cod:'fr'; nome:'Francês';   som:'EDFRANC'),
        (cod:'it'; nome:'Italiano';  som:'EDITALI'),
        (cod:'de'; nome:'Alemão';    som:'EDALEMAO'),
        (cod:'eo'; nome:'Esperanto';    som:'EDESPERANTO')
    );

{--------------------------------------------------------}

function abrirTraduvox (progTraduvox, linguaOrig, linguaDest,nomeArqOrig, nomeArqDest: string): boolean;
begin
    if pos(' ',  nomeArqOrig) <> 0 then
        begin
            nomeArqOrig := '"' + nomeArqOrig + '"';
            nomeArqDest := '"' + nomeArqDest + '"';
        end;

    if executaProg ('"' + progTraduvox + '"' , '', linguaOrig + ' ' + linguaDest + ' ' + nomeArqOrig + ' ' + nomeArqDest) >= 32 then
        begin
            esperaProgVoltar;
            while sintFalando do waitMessage;
            result := true;
        end
    else
        result := false;
end;

{--------------------------------------------------------}
{                  Retorna o diretório de instalação do Dosvox
{--------------------------------------------------------}

function pegaDirDosvox: string;
var dirDosvox: string;
begin
    dirDosvox := sintAmbiente ('DOSVOX', 'PGMDOSVOX');
    if dirDosvox = '' then
        dirDosvox := 'c:\winvox';
    if dirDosvox[length(dirDosvox)] <> '\' then
        dirDosvox := dirDosvox + '\';

    result := dirDosvox;
end;

{-------------------------------------------------------------}
{   Deleta um arquivo, recebendo o nome.
{-------------------------------------------------------------}

function deletaArquivo(nomeArq: string): boolean;
var
    arqTemp: text;
begin
    assign (arqTemp, nomearq);
    {$I-}  erase (arqTemp);  {$I+}
    result := ioresult = 0;
end;

{--------------------------------------------------------}

function verificarTotalCaracteresBloco: boolean;
var
    i, k: integer;
    total: int64;
begin
    total := 0;
    for i := inibloco to fimbloco do
        for k := 1 to length(texto[i]) do
            if texto[i][k] <> ' ' then
                inc (total);

    result := total <= TOTALCARACTERTRADUZ;
end;

{--------------------------------------------------------}

function gravarLinhasNoArq (linhaIni, linhaFim: integer; nomeArq:  string): boolean;
var
    i: integer;
    arq: text;
begin
    assign (arq, nomeArq);
    {$i-} rewrite (arq); {$I+}
    if ioresult <> 0 then
        begin
            fala ('EDERRESC');
            result := false;
            exit;
        end;

    For i := linhaIni to linhaFim Do
        begin
            {$I-} writeln (arq, texto[i]); {$I+}
            if ioresult <> 0 then
                begin
                    fala ('EDERRESC');
                    {$I-} close (arq); {$I+}
                    if ioresult <> 0 then;
                    deletaArquivo (nomeArq);
                    result := false;
                    exit;
                end;
        end;

    {$I-} close (arq); {$I+}
    result := ioresult = 0;
end;

{-------------------------------------------------------------}

function carregaLinhasArq (nomeArq: string; var linhasTexto: TStringList): boolean;
begin
    linhasTexto := TStringList.create;
    carregaLinhasArq := true;
    try
        linhasTexto.loadFromFile (nomeArq);
    except
         carregaLinhasArq := false;
    end;
end;

{--------------------------------------------------------}

function gravarArqNoTexto (nomeArq: string): boolean;
var
    i, salvaPosY: integer;
    linhasTexto: TStringList;
begin
    if not carregaLinhasArq (nomeArq, linhasTexto) then
        begin
            fala ('EDARQNAO');
            result := false;
            exit;
        end;

    gravarDesfazer;

    salvaPosY :=  fimBloco + 1;
    posy := salvaPosY;
    if fimBloco = maxLinhas then
        texto.append('');

    for i := 0 to (linhasTexto.Count - 1) do
        begin
            insereLinha (linhasTexto[i], false);
            posy := posy + 1;
        end;

    linhasTexto.Free;

    fimBloco := posy-1;
    iniBloco := salvaPosy;
posy := salvaPosy;
    posx := 1;
    fala ('EDBLKCRG');
end;

{--------------------------------------------------------}

procedure pegaLinguaDestDireto (var linguaDest: string);
var
    s: string;
    erro, nDest: integer;
begin
    s := sintAmbiente ('EDIVOX', 'LINGUADESTINO', '2');
    val (s, nDest,  erro);
    if (erro <> 0) or (nDest < 1) or (nDest > maxLinguas) then nDest := 2;
    linguaDest := linguas[nDest].cod;
end;

{--------------------------------------------------------}

function pegaLinguaDest (var linguaDest: string): boolean;
var i, n: integer;
begin
    linguaDest := '';

    fala('EDLINDST');  {'Selecione a língua destino com as setas: '}
    popupMenuCria(40, 9, 15, maxLinguas, RED);
    for i := 1 to maxLinguas do
        with linguas[i] do
            popupMenuAdiciona(som, nome);
    n := popupMenuSeleciona;

    if n = 0 then
        result := false
    else
        begin
            linguaDest := linguas[n].cod;
            result := true;
        end;
end;

{--------------------------------------------------------}

procedure trataTraduvox (traduzDireto: boolean);
var
    progTraduvox, dirDosvox, dirLixeira: string;
    linguaDest: string;
    nomeArqOrig, nomeArqDest: string;

begin
    if blocoInvalido then
        begin
            fala ('EDBLKINV');   { bloco invalido }
            exit;
        end;

    if not verificarTotalCaracteresBloco then
        begin
            fala ('EDGRANDE'); {'Bloco muito grande'}
            fala ('EDNPTRMA'); {'não pode ter mais de '}
            sintetiza (intToStr(TOTALCARACTERTRADUZ));
            fala ('EDLETRAS'); {'letras'}
            exit;
        end;

    dirDosvox := pegaDirDosvox;
    progTraduvox := sintAmbiente ('EDIVOX', 'PROGTRADUTOR', dirDosvox + 'traduvox.exe');
    if not FileExists(progTraduvox) then
        begin
            fala ('EDPRONEN'); {'Programa não encontrado'}
            sintetiza (progTraduvox);
            exit;
        end;

    if traduzDireto then
        pegaLinguaDestDireto (linguaDest)
    else
    if not pegaLinguaDest (linguaDest) then
        begin
            fala ('EDDESIST');    {'Desistiu'}
            exit;
        end;

    dirLixeira := sintAmbiente ('DOSVOX', 'DIRLIXEIRA', dirDosvox + 'Lixeira');
    if dirLixeira[length(dirLixeira)] <> '\' then dirLixeira := dirLixeira + '\';

    nomeArqOrig := dirLixeira + 'ORI_AUTO_Traduvox.txt';
    if not gravarLinhasNoArq (inibloco, fimbloco, nomeArqOrig) then exit;
    nomeArqDest := dirLixeira + 'DEST_' + linguaDest + '_Traduvox.txt';
    deletaArquivo (nomeArqDest);

    if not abrirTraduvox (progTraduvox, 'AUTO', linguaDest,nomeArqOrig, nomeArqDest) then
        begin
            fala ('EDNEXEC'); {'Não pude executar'}
            deletaArquivo (nomeArqOrig);
            exit;
        end;
    deletaArquivo (nomeArqOrig);

    gravarArqNoTexto (nomeArqDest);
    deletaArquivo (nomeArqDest);
end;

{--------------------------------------------------------}

begin
end.
