{
    VoxTube - utilitário de acessibilização do YouTube  ;

Processamento da lista de filmes;

    Autores:
        Antonio Borges,
        Fabiano Ferreira,
        Glauco Constantino,
        Neno Albernaz,
        Patrick Barbosa;

    Versão 1.0 em Fevereiro de 2013;

    Versão 6.0 em Março de 2024;
}

unit vt_par;

interface

function geraListaDeFilmes (lidoYoutube: string): integer;

implementation
uses
    dvwin,
    sysutils,
vt_var,
vt_aux,
    classes;

{--------------------------------------------------------}
{         limpa a lista de filmes e seus registros
{--------------------------------------------------------}

{--------------------------------------------------------}
{     gera a lista de filmes a partir de tagsPagina
{--------------------------------------------------------}

function geraListaDeFilmes (lidoYoutube: string): integer;
                                    // retorna quantos links achou

//descarta os resultados anteriores
procedure  DescResuAnte(var s : string; quandesc: integer);
var i, p : integer;
begin
for i:= 1 to quandesc do
begin
p := pos('<n>',s);
p := p + 3;
s := copy(s,p,length(s)-(p-1));
end;
end;

var
    i, p, j: integer;
x : string;

const youtube = 'https://www.youtube.com/watch?v=';
begin
    result := 0;
quantoslinks := 0;
descresuante(lidoyoutube,limitemin);

    p := pos ('\',lidoyoutube);
if p = 0 then exit;

for i:= 0 to limite-1 do
 begin
    p := pos ('\',lidoyoutube);
if p = 0 then break;
p := p-1;
x := copy(lidoyoutube,1,p);

        for j := length(x)-3 downto 1 do
            if ord(x[j]) >= $f0 then
                begin
                    delete (x, j, 3);
                    x[j] := '*';
                end;

filme.titulo[i] := utf8toansi(copy(x,1,999999));
p := p + 2;
lidoyoutube := copy(lidoyoutube,p,length(lidoyoutube)-(p-1));

    p := pos ('\',lidoyoutube);
p := p-1;
filme.paginaweb[i] := youtube + copy(lidoyoutube,1,p);
p := p + 2;
lidoyoutube := copy(lidoyoutube,p,length(lidoyoutube)-(p-1));

    p := pos ('\',lidoyoutube);
p := p-1;
filme.duracao[i] := copy(lidoyoutube,1,p);
p := p + 2;
lidoyoutube := copy(lidoyoutube,p,length(lidoyoutube)-(p-1));

    p := pos ('\',lidoyoutube);
p := p-1;
filme.autor[i] := utf8toansi(copy(lidoyoutube,1,p));

p := p + 2;
lidoyoutube := copy(lidoyoutube,p,length(lidoyoutube)-(p-1));

    p := pos ('\',lidoyoutube);
p := p-1;
filme.visto[i] := copy(lidoyoutube,1,p);

while (pos('.',filme.visto[i]) > 0) do
begin

delete (filme.visto[i],pos('.',filme.visto[i]),1);
end;

delete (filme.visto[i],pos(' ',filme.visto[i]),999);
p := p + 2;
lidoyoutube := copy(lidoyoutube,p,length(lidoyoutube)-(p-1));

    p := pos ('<n>',lidoyoutube);
p := p-1;
filme.datapub[i] := utf8toansi(copy(lidoyoutube,1,p));
p := p + 4;
lidoyoutube := copy(lidoyoutube,p,length(lidoyoutube)-(p-1));

listadefilmes[i] := filme.titulo[i]+' - '+filme.duracao[i]+' - por '+filme.autor[i];

quantoslinks := quantoslinks + 1;
        end;

    result := quantosLinks;
end;

end.
