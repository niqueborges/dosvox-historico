{--------------------------------------------------------}
{                                                        }
{    Programa de palavras cruzadas                       }
{                                                        }
{    Módulo de tratamento das legendas                   }
{                                                        }
{    Autores: José Antonio Borges                        }
{             Jorge Carlos dos Santos                    }
{                                                        }
{    Em agosto/2010                                      }
{                                                        }
{--------------------------------------------------------}

unit crlegend;

interface
uses dvwin, dvcrt, sysUtils, crvars, crmsg, crdesen;

procedure removeTodasAsLegendas;
function temLegenda (x, y: integer; dir: TDirecao): boolean;
function pegaLegenda (x, y: integer; dir: TDirecao): string;
procedure incluiLegenda (x, y: integer; dir: TDirecao; novaLegenda: string);
procedure removeLegenda (x, y: integer; dir: TDirecao);
function temAlgumaLegenda (x, y: integer): boolean;
procedure criaLegenda (x, y: integer);
procedure consisteLegendas;

implementation

uses crArq;

function temLegenda (x, y: integer; dir: TDirecao): boolean;
begin
    if dir = HORIZ then
        temLegenda := legendasHoriz [y, x] <> ''
    else
        temLegenda := legendasVert [y, x] <> '';
end;

function pegaLegenda (x, y: integer; dir: TDirecao): string;
begin
    if dir = HORIZ then
        result := legendasHoriz [y, x]
    else
        result := legendasVert [y, x];
end;

procedure incluiLegenda (x, y: integer; dir: TDirecao; novaLegenda: string);
begin
    if dir = HORIZ then
	legendasHoriz [y, x] := novaLegenda
    else
        legendasVert [y, x] := novaLegenda;
end;

procedure removeTodasAsLegendas;
var x, y: integer;
begin
    for x := 1 to MAXDIM do
        for y := 1 to MAXDIM do
             begin
                 removeLegenda (x, y, HORIZ);
                 removeLegenda (x, y, VERT);
             end;
end;

procedure removeLegenda (x, y: integer; dir: TDirecao);
begin
    if dir = HORIZ then
	legendasHoriz [y, x] := ''
    else
	legendasVert [y, x] := ''
end;

function temAlgumaLegenda (x, y: integer): boolean;
begin
    temAlgumaLegenda := temLegenda (x, y, HORIZ) or temLegenda (x, y, VERT);
end;

procedure veSePodeLegendar (x, y: integer; var podeHoriz, podeVert: boolean);
var
    acima, abaixo, esq, dir: boolean;
begin
    if (modelo[y, x] = '*') or (modelo[y, x] = '.') then
        begin
            podeHoriz := false;
            podeVert  := false;
            exit;
        end;

    acima  := (y > 1)  and (modelo[y-1, x] <> '.') and (modelo[y-1, x] <> '*');
    abaixo := (y < ny) and (modelo[y+1, x] <> '.') and (modelo[y+1, x] <> '*');
    esq    := (x > 1)  and (modelo[y, x-1] <> '.') and (modelo[y, x-1] <> '*');
    dir    := (x < nx) and (modelo[y, x+1] <> '.') and (modelo[y, x+1] <> '*');

    podeHoriz := (not esq) and dir;
    podeVert  := (not acima) and abaixo;
end;

procedure criaLegenda (x, y: integer);
var
    direcao: TDirecao;
    podeHoriz, podeVert: boolean;
    c: char;
    s, leg: string;

begin
    areaLegendas;
    clrscr;

    sintWriteln (chr((x-1) + ord('A')) + ' ' + intToStr(y));
    sintetiza(s);

    direcao := INDEFINIDA;

    veSePodeLegendar (x, y, podeHoriz, podeVert);

    if (modelo [y, x] = '*') or (not (podeHoriz or podeVert)) then
        begin
            mensagem ('CRIMPOSL', 1);  {'Impossível criar legenda aqui'}
            todaTela;
            exit;
        end;

    if podeHoriz and podeVert then
        begin
            mensagem ('CRHORVER', 0);  {'Horizontal ou Vertical? '}
            c := readkey;
            writeln (c);
            if upcase (c) = 'H' then podeVert := false
                                else podeHoriz := false;
        end;

    if podeHoriz then
        begin
	    mensagem ('CRHORIZ', 1);   {'Horizontal'}
	    direcao := HORIZ;
        end
    else
    if podeVert then
	begin
            mensagem ('CRVERT',  1);   {'Vertical'}
            direcao := VERT;
        end;

    writeln;
    if temLegenda (x, y, direcao) then
        begin
            leg := pegaLegenda(x, y, direcao);
            mensagem ('CRMODLEG', 1);    {'Modifique a legenda existente'}
        end
    else
        begin
            leg := '';
            mensagem ('CRDIGLEG', 1);    {'Digite a legenda'}
        end;

    c := sintEdita(leg, wherex, wherey+1, 80, true);
    if c = ESC then
        begin
            writeln;
            mensagem ('CRDESIST', 1);    {'Desistiu'}
            todaTela;
            exit;
        end;

    writeln;
    writeln;

    leg := trim (leg);
    if leg <> '' then
        begin
            incluiLegenda (x, y, direcao, leg);
            mensagem ('CROK', 1);    {'Ok'}
        end;

    todaTela;
end;

procedure consisteLegendas;
var x, y: integer;
    podeHoriz, podeVert: boolean;
    erro, erro2: boolean;
begin
    areaLegendas;
    clrscr;
    erro := false;
    erro2 := false;

    mensagem ('CRVERLEG', 2);   {'Verificação de legendas faltando ou sobrando'}

    for y := 1 to ny do
        for x := 1 to nx do
            begin
                veSePodeLegendar (x, y, podeHoriz, podeVert);
                if podeHoriz then
                    begin
                        if not temLegenda(x, y, HORIZ) then
                            begin
                                sintWriteln ('HORIZONTAL ' + chr((x-1) + ord('A')) + ' ' + intToStr(y));
                                erro := true;
                            end;
                    end
                else
                   if temLegenda(x, y, HORIZ) then
                       begin
                           legendasHoriz[y, x] := '';
                           erro2 := true;
                       end;
            end;

    for y := 1 to ny do
        for x := 1 to nx do
            begin
                veSePodeLegendar (x, y, podeHoriz, podeVert);
                if podeVert then
                    begin
                        if not temLegenda(x, y, VERT) then
                            begin
                                sintWriteln ('VERTICAL ' + chr((x-1) + ord('A')) + ' ' + intToStr(y));
                                erro := true;
                            end;
                    end
                else
                   if temLegenda(x, y, VERT) then
                       begin
                           legendasHoriz[y, x] := '';
                           erro2 := true;
                       end;
            end;

    if erro2 then
        mensagem ('CRAJUAUT', 1);   {'Lista de legendas foi ajustada automaticamente'}
    if not erro then
        mensagem ('CRSEMERR', 1);   {'Não há falta de legendas'}

    todaTela;
end;

end.

