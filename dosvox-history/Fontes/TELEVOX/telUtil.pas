{--------------------------------------------------------}
{               Televox - rotinas utilitarias
{--------------------------------------------------------}

unit telUtil;
interface

uses windows, shellApi, sysutils, dvlenum,
     dvcrt, dvWin, winsock,
     telVars, telMsg, telTela;

procedure falaNumRegs (nomeAgenda: boolean);
procedure falaQuantosSelecionados;
procedure marcaTodos;
procedure desmarcaTodos;
procedure marcaEste (i: integer);
procedure desmarcaEste (i: integer);
procedure marcaOuDesmarcaUltimoLido;
function semAcentos (s: string): string;
procedure atualizaItem (qual, posTab: integer; campo: string);
procedure removeTodosItens (posTab: integer);
procedure removeRegistro (postab: integer);
procedure removeUltimo;
procedure removeRegsDuplicados;
procedure naoImplem;

implementation

{--------------------------------------------------------}
{              informa numero de registros
{--------------------------------------------------------}

procedure falaNumRegs (nomeAgenda: boolean);
var s: string;
begin
    str (cadastrados, s);
    if nomeAgenda then
        sintetiza (nomeCadastro);
    msgBaixo ('TVLIDOS', nomeCadastro + ' - ' + pegaTextoMensagem ('TVLIDOS') + s); {'Registros lidos: '}
    falaNumeroConv (numeroParaString (cadastrados), MASCULINO);
end;

{--------------------------------------------------------}
{       Fala quantos selecionados
{--------------------------------------------------------}

procedure falaQuantosSelecionados;
var i, quantos: integer;
begin
    quantos := 0;
    for i := 1 to cadastrados do
        if listaFone[i]^.status <> 0 then
            quantos := quantos + 1;

    falaNumeroConv (numeroParaString (quantos), MASCULINO);
    if quantos > 1 then
        msgBaixo ('TVSELSDE', intToStr(quantos) + ' ' + pegaTextoMensagem ('TVSELSDE') + ' ' + intToStr (cadastrados)) {'selecionados de'}
    else
        msgBaixo ('TVSELEDE', intToStr(quantos) + ' ' + pegaTextoMensagem ('TVSELEDE') + ' ' + intToStr (cadastrados)); {'selecionado de'}
    falaNumeroConv (numeroParaString (cadastrados), MASCULINO);
end;
{--------------------------------------------------------}
{               Seleciona todos os registros
{--------------------------------------------------------}

procedure marcaTodos;
var i: integer;
begin
    for i := 1 to cadastrados do
        listaFone[i]^.status := listaFone[i]^.status or SELECIONADO;
    sintbip;
end;

{--------------------------------------------------------}
{               Tira a seleçã de todos os registros
{--------------------------------------------------------}

procedure desmarcaTodos;
var i: integer;
begin
    for i := 1 to cadastrados do
        listaFone[i]^.status := 0;
end;

{--------------------------------------------------------}
{               Seleciona o registro desejado
{--------------------------------------------------------}

procedure marcaEste (i: integer);
begin
    if (i <= 0) or (i > cadastrados) then exit;
    listaFone[i]^.status := listaFone[i]^.status or SELECIONADO;
    sintbip;
end;

{--------------------------------------------------------}
{               tira a seleção do registro desejado
{--------------------------------------------------------}

procedure desmarcaEste (i: integer);
begin
    if (i <= 0) or (i > cadastrados) then exit;
    listaFone[i]^.status := 0;
end;

{--------------------------------------------------------}
{               Seleciona ou tira a seleção do ultimo registro lido
{--------------------------------------------------------}

procedure marcaOuDesmarcaUltimoLido;
begin
    if (posAtual <= 0) or (posAtual > cadastrados) then exit;
    if listaFone[posAtual]^.status = SELECIONADO then
        desmarcaEste (posAtual)
    else
    marcaEste (posAtual);
end;

{--------------------------------------------------------}
{     transforma cadeia em maiusculos nao acentuados
{--------------------------------------------------------}

function semAcentos (s: string): string;
const
    tabMaiuscPC: array [#$80..#$ff] of char = (

    'C','U','E','A','A','A','A','C','E','E','E','I','I','I','A','A',
    'E','þ','þ','O','O','O','U','U','Y','O','U','þ','þ','þ','þ','þ',
    'A','I','O','U','N','N','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ',
    'A','A','A','A','A','A','‘','C','E','E','E','E','I','I','I','I',
    'þ','N','O','O','O','O','O','X','þ','U','U','U','U','Y','þ','þ');

var
    s2: string;
    i: integer;

begin
    s2 := s;
    for i := 1 to length (s2) do
        if s2[i] in ['a'..'z'] then
            s2[i] := upcase (s2[i])
        else
        if s2[i] >= #$80 then
            s2[i] := tabMaiuscPC [s2[i]];

    semAcentos := s2;
end;

{--------------------------------------------------------}
{                    atualiza um item
{--------------------------------------------------------}

procedure atualizaItem (qual, posTab: integer; campo: string);
var pcampo: pString;
begin
    if qual > MAXCAMPOS then exit;

    pcampo := listaFone[postab]^.campoCad[qual];

    if pcampo <> NIL then
        freemem (pcampo, length(pcampo^)+1);

    if campo = '' then
        pcampo := NIL
    else
        begin
            getmem (pcampo, length (campo)+1);
            pcampo^ := campo;
        end;

    listaFone[postab]^.campoCad[qual] := pcampo;
end;

{--------------------------------------------------------}
{          remove todos os itens de um registro
{--------------------------------------------------------}

procedure removeTodosItens (posTab: integer);
var qual: integer;
begin
    for qual := 1 to numCampos do
         atualizaItem (qual, posTab, '');
end;

{--------------------------------------------------------}
{                   remove um registro
{--------------------------------------------------------}

procedure removeRegistro (postab: integer);
var i: integer;
begin
    removeTodosItens (postab);
    dispose (listaFone [postab]);
    if postab <= cadastrados then
        begin
            for i := postab to cadastrados-1 do
                listaFone [i] := listaFone [i+1];
            cadastrados := cadastrados - 1;
        end;
end;

{--------------------------------------------------------}
{       Remove o último registro lido
{--------------------------------------------------------}

procedure removeUltimo;
var c, c2: char;
s: string;
begin
    if (posAtual <= 0) or (posAtual > cadastrados) then
        begin
            msgBaixo ('TVNPOS', ''); {'Registro desconhecido: não apagado.'}
            exit;
        end;

    s := mostraItem (1, posAtual, true);
    imprime (FALSE);
    liga;

    sintetiza (s);
    msgBaixo ('TVCONFRM', ''); {'Confirma remoção deste (S/N) ?'}
    sintLeTecla (c, c2);
    if (upcase(c) <> 'S') then
        begin
            msgBaixo ('TVCANC', ''); {'Operação cancelada'}
            exit;
        end
    else
        msgBaixo ('TVREM', ''); {'Removido'}

    removeRegistro (posAtual);
    posAtual := posAtual -1;
    if posAtual <= 0 then posAtual := 1;
end;

{--------------------------------------------------------}
{       Remove os registros idênticos
{--------------------------------------------------------}

procedure removeRegsDuplicados;
var
    i, j, nc, auxCadastrados: integer;
    apagaRegistro: boolean;
    c: char;
begin
    if cadastrados < 2 then exit;
    msgBaixo ('TVREREDU', ''); {'Removendo registros duplicados ...'}
    repeat
        msgBaixo ('TVAGDORD', ''); {'A agenda está ordenada?'}
        c := upcase (sintReadkey);
    until c in ['S', 'N', ENTER, ESC];
    if c in ['N', ESC] then
        begin
            msgBaixo ('TVORAGAN', ''); {'Ordene a agenda antes de realizar esta operação'}
        exit;
        end;
    auxCadastrados := cadastrados;
    for i := auxCadastrados downto 2 do
        for j := (i-1) downto 1 do
            begin
                apagaRegistro := true;
                for nc := 1 to numCampos do
                if obtemItem (nc, i) <> obtemItem (nc, j) then
                    begin
                        apagaRegistro := false;
                        break;
                    end;
                if apagaRegistro then
                    begin
                        removeRegistro (i);
                        break;
                    end
                else
                if obtemItem (1, i) <> obtemItem (1, j) then
                    break;

            end;

    msgBaixo ('TVOK',''); {'Ok'}
    falaNumRegs (false);
end;

{--------------------------------------------------------}
{                    não implementados
{--------------------------------------------------------}

procedure naoImplem;
begin
    writeln;
    mensagem ('TVNIMPLE', 2);    {'Não foi ainda implementado'}
end;


end.
