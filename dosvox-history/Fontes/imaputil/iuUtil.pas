{--------------------------------------------------------}
{                                                        }
{    Programa de acesso rápido usando imap               }
{                                                        }
{    Rotinas utilitárias                                 }
{                                                        }
{    Autor: Neno Henrique da Cunha Albernaz              }
{                                                        }
{    Em Fevereiro/2023                                   }
{                                                        }
{--------------------------------------------------------}

unit iuUtil;

interface

uses
    dvcrt,
    dvwin,
    windows,
    sysutils,
    classes,
//    dvinet,
//    dvssl,
    dvform,
//    dvarq,
//    iurede,
//    iuenvel,
//    iuBusca,
    iuvars,
    iumsg;

procedure infoDataCarta (ncar: integer; listaDeCartas: TList);
function pegarRemetenteCarta (ncar: integer; listaDeCartas: TList): string;
//function pegaAssuntoCarta(nCar: integer; listaDeCartas: TList): string;
procedure infoCarta (ncar: integer; listaDeCartas: TList);
procedure falaQualItemDeQuantos (nItem, totalItens: integer; Selecionados: boolean);
procedure falaAssunto (nCar: integer; completo: boolean; listaDeCartas: TList);

implementation

//var
//    indEnvel, tamEnvel: array of integer;

{--------------------------------------------------------}
{       Informa a data de envio da carta.
{--------------------------------------------------------}

procedure infoDataCarta (ncar: integer; listaDeCartas: TList);
var
    p: PEnvelope;
begin
    p := listaDeCartas[ncar];
    sintWriteln (p^.data);
    while not keypressed do waitMessage;
end;

{--------------------------------------------------------}
{       Retorna o remetente da carta.
{--------------------------------------------------------}

function pegarRemetenteCarta (ncar: integer; listaDeCartas: TList): string;
var
    p: PEnvelope;
begin
    p := listaDeCartas[ncar];

    result := p^.enviador;
end;

{--------------------------------------------------------}
{       Retorna o assunto da carta.
{--------------------------------------------------------}

function pegaAssuntoCarta(nCar: integer; listaDeCartas: TList): string;
var
    p: PEnvelope;
begin
    p := listaDeCartas[ncar];

    result := p^.assunto;
end;

{--------------------------------------------------------}
{       exibe informações sobre a carta                        }
{--------------------------------------------------------}

procedure infoCarta (ncar: integer; listaDeCartas: TList);
var
    p: PEnvelope;

begin
    p := listaDeCartas[ncar];

    limpaBaixo (21);
    writeln ('--------------------------------------------------------------------------------');
    gotoxy (1, 22);
    mensagem ('IUDATA', 0);    {'Data: '}
    sintWriteln (p^.data);
    sintClek;
    mensagem ('IUENVPOR', 0);  {'Enviado por: '}
    sintWriteln  (p^.enviador);
    sintClek;
    mensagem ('IUASSUNT', 0);  {'Assunto: '}
    sintWrite (p^.assunto);

    while not keypressed do waitMessage;
end;

{-------------------------------------------------------------}
{       Informa o total de itens do folheamento, em qual está ou as selecionadas do  total.
{-------------------------------------------------------------}

procedure falaQualItemDeQuantos (nItem, totalItens: integer; Selecionados: boolean);
begin
    if selecionados then
        nItem := folheiaNumSelec (nitem);
    sintetiza (intToStr (nItem));
    if selecionados then
        if nItem >1 then
            mensagem ('IUSELECS', -1) {'selecionadas'}
        else
            mensagem ('IUSELECI', -1); {'selecionada'}
    mensagem ('IUDE', -1); {'de'}
    sintetiza (intToStr(totalItens));
end;

{--------------------------------------------------------}
{       Retorna o prefixo do assunto
{--------------------------------------------------------}

function pegaPrefixoAssunto (assunto: string): string;
var k, k2, k3, k4, k5, k6: integer;
    l, r: string;
begin
    result := '';
    k := pos ('[{', assunto);
    if (trim(assunto) = '') or (k > 0) then exit;

    l := '';
    r := '';

    k := pos ('[', assunto);
    k2 := pos (']', assunto);
    if (k > 0) and (k2 > 0) and (k2 > k) then
        begin
            l := copy (assunto, k, k2 - k + 1);
        end;

    k2 := pos ('{', assunto);
    k3 := pos ('}', assunto);
    if (k2 > 0) and (k3 > 0) and (k3 > k2) then
        if (k < k2) and (k > 0) then
            l := l + ' ' + copy (assunto, k2, k3 - k2 + 1)
        else
        if l <> '' then
            l := copy (assunto, k2, k3 - k2 + 1) + ' ' + l
        else
            l := copy (assunto, k2, k3 - k2 + 1);

    if ((k2 < k) or (k = 0)) and (k2 > 0) then k := k2;

    k2 := pos('RES: ', maiuscansi(assunto));
    k3 := pos('ENC: ', maiuscansi(assunto));
    k4 := pos('RE: ', maiuscansi(assunto));
    k5 := pos('EN: ', maiuscansi(assunto));
    k6 := pos('FW: ', maiuscansi(assunto));

    if ((k3 < k2) or (k2 = 0)) and (k3 > 0) then k2 := k3;
    if ((k4 < k2) or (k2 = 0)) and (k4 > 0) then k2 := k4;
    if ((k5 < k2) or (k2 = 0)) and (k5 > 0) then k2 := k5;
    if ((k6 < k2) or (k2 = 0)) and (k6 > 0) then k2 := k6;
    if k2 > 0 then
        begin
            r := copy (assunto, k2, 4);
            if (r <> '') and (r[4] <> ' ') then r := r + ' ';
        end;

    if k2 < k then
        assunto := r + l + ' '
    else
    if k = 0 then
        assunto := r
    else
        assunto := l + ' ' + r;

    result := assunto;
end;

{--------------------------------------------------------}
{       Limpa o assunto.
{--------------------------------------------------------}

function limpaAssuntoLista (assunto: string): string;
var k, k2: integer;
label fim;
begin
    k := pos ('[{', assunto);
    if k > 0 then goto fim;

    k := pos ('[', assunto);
    k2 := pos (']', assunto);
    while (k <> 0) and (k2 <> 0) and (k2 > k) do
        begin
            delete (assunto, k, k2-k+1);
            k := pos ('[', assunto);
            k2 := pos (']', assunto);
        end;

    k := pos ('{', assunto);
    k2 := pos ('}', assunto);
    while (k <> 0) and (k2 <> 0) and (k2 > k) do
        begin
            delete (assunto, k, k2-k+1);
            k := pos ('{', assunto);
            k2 := pos ('}', assunto);
        end;

    while (assunto <> '') and ( assunto[1] = ' ') do
        delete (assunto, 1,1);
fim:

    result := assunto;
end;

function limpaAssunto (assunto: string): string;
var k, k2, k3: integer;
label fim;
begin
    k := pos ('[{', assunto);
    if (trim(assunto) = '') or (k > 0) then goto fim;

    k := pos ('RES: ', maiuscansi(assunto));
    k2 := pos ('ENC: ', maiuscansi(assunto));
    while (k <> 0) or (k2 <> 0) do
        begin
            if k = 0 then k := k2;
            delete (assunto, k, 5);
            k := pos ('RES: ', maiuscansi(assunto));
            k2 := pos ('ENC: ', maiuscansi(assunto));
        end;

    k := pos ('RE: ', maiuscansi(assunto));
    k2 := pos ('EN: ', maiuscansi(assunto));
    k3 := pos ('FW: ', maiuscansi(assunto));
    while (k <> 0) or (k2 <> 0) or (k3 <> 0) do
        begin
            if k = 0 then k := k2;
            if (k = 0) and ( k2 = 0) then k := k3;
            delete (assunto, k, 4);
        k := pos ('RE: ', maiuscansi(assunto));
            k2 := pos ('EN: ', maiuscansi(assunto));
            k3 := pos ('FW: ', maiuscansi(assunto));
        end;

    assunto := limpaAssuntoLista (assunto);

    while (assunto <> '') and ( assunto[1] = ' ') do
        delete (assunto, 1,1);

fim:

    result := assunto;
end;

procedure falaAssunto (nCar: integer; completo: boolean; listaDeCartas: TList);
var s: string;
begin
    s := pegaAssuntoCarta(nCar, listaDeCartas);
    if completo then
        s := pegaPrefixoAssunto(s) + limpaAssunto(s)
    else
        s := limpaAssunto(s);
    if trim(s) = '' then
        s := 'Nulo';
    sintetiza (s);
end;

{--------------------------------------------------------}

begin
end.
