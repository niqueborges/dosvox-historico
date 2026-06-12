{
    VoxTube - utilitário de acessibilização do YouTube  ;

Rotinas de busca

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

unit vt_bus;

interface
function escolheBusca: string;
procedure adicionaAosUltimos (chaveBusca: string);
procedure processaBusca (busca: string);

implementation
uses
dvcrt,
dvwin,
dvform,
sysutils,
vt_aux,
vt_fol,
vt_msg,
vt_net,
vt_par,
vt_var;

function escolheBusca: string;
var i: integer;
begin
    garanteEspacoTela (10);
    popupMenuCria(wherex, wherey, 80, 10, MAGENTA);
    for i := 1 to 10 do
        if ultimasBuscas[i] <> '' then
            popupMenuAdiciona('', ultimasBuscas[i]);
    popupMenuSeleciona;
    result := opcoesItemSelecionado;
end;

{-----------------------------------------------------------}
{          rotinas de criação e exibição da janela
{-----------------------------------------------------------}

procedure adicionaAosUltimos (chaveBusca: string);
var i, j: integer;
begin
    for i := 1 to 10 do
        begin
            if chaveBusca = ultimasBuscas[i] then
                begin
                    for j := i to 10-1 do
                        ultimasBuscas[j] := ultimasBuscas[j+1];
                    ultimasBuscas[10] := '';
                end;
        end;

    if (chaveBusca <> '') and (chaveBusca <> ultimasBuscas[1]) then
       begin
           for i := 10 downto 2 do
               ultimasBuscas[i] := ultimasBuscas[i-1];
           ultimasBuscas[1] := chaveBusca;
           for i := 1 to 10 do
               sintGravaAmbiente ('VOXTUBE', intToStr(i), ultimasBuscas[i]);
       end;
end;


procedure processaBusca (busca: string);
var
    comando: string;
    s: string;
    quantosLinks: integer;
    c1: char;

begin
    c1 := ' ';
    repeat
        gotoxy (1, 3);

limitemin := (limite*pagatual) - (limite-1);

        comando := '/vtbusca/?q='+stringToURL(AnsiToUtf8(busca))+'&limite='+inttostr(limite*pagatual);

        s := pedeAoYoutube (comando);
        quantosLinks := 0;
        if s <> '' then
            begin
                quantosLinks := geraListaDeFilmes (s);
                if montaFolheamento then
                    c1 := folheiaVideos;
                folheiaDestroi;

                if (quantosLinks = 0) and (pagAtual > 1) then
                    begin
                        sintBip; sintBip;
                        mensagem ('VTULTPGV', 0);   {'Última página, voltando.'}
                        pagAtual := pagAtual - 1;
                        quantosLinks := -1;
                    end;
            end;
    until (s = '') or (c1 = ESC) or
           ((quantosLinks = 0) and (pagAtual = 1));
end;

end.
