{
    VoxTube - utilitário de acessibilização do YouTube  ;

Rotinas de folheamento dos vídeos;

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

unit vt_fol;
interface
function montaFolheamento: boolean;   // retorna também a lista de filmes
function folheiaVideos: char;
implementation
uses dvcrt,
dvform,
windows,
vt_var,
vt_msg,
vt_fun,
vt_men,
dvwin;

function montaFolheamento: boolean;   // retorna também a lista de filmes
var i : integer;

begin
if quantoslinks = 0 then exit;
    window (1, 1, 80, 25);
    gotoxy (1, 3);
    clreol;
if sintfalartudo then begin
    mensagem('VTNUMLID', 0);  {'Número de registros lidos: '}
    sintWriteInt (quantoslinks);
    mensagem('VTPAG', 0);  {'Página: '}
sintwriteint(pagatual);
end;
    writeln;
    textbackground (RED);
    writeln ('-------------------------------------------------------------------------------');
    textbackground (BLACK);

    window (1, wherey, 80, 25);
    folheiaCria (wherex, wherey, 80, 30);
    for i := 0 to quantoslinks-1 do
        begin
            folheiaAdiciona(listadefilmes[i]);

        end;

    result := true;
end;

{--------------------------------------------------------}
{       folheia os vídeos informados pelo youtube
{--------------------------------------------------------}

function folheiaVideos: char;
var c1, c2: char;
    ultFolheado: integer;
    mudouPagina, podeFalar: boolean;

begin
    ultFolheado := 1;
mudoupagina := false;
    c1 := ' ';
    podeFalar := true;
    repeat
        clrscr;
        if folheiaExecuta(ultFolheado, ultFolheado, c1, c2, podeFalar) then
            processaFuncao (c1, c2, (GetKeyState(VK_SHIFT) < 0), ultFolheado-1, mudouPagina)
        else
sintbip;

        if (c1 = #0) and (c2 in [DIR, ESQ, CTLESQ, DEL, F8, CTLF8]) then
            podeFalar := false
        else
            podeFalar := true;

    until mudouPagina or (c1 = ESC);
    result := c1;
end;

end.
