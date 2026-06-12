unit epExibeLivro;
interface

uses
    DvCrt,
    DvWin,
    Classes,
    SysUtils,
    epmsg,
    epvars,
    eptrataHTML;

procedure exibeTXT;

implementation

{--------------------------------------------------------}
{           carrega o txt em uma stringlist
{--------------------------------------------------------}

function abreTXT(endereco: string): TStringList;

var
    arquivo: text;
    livro:   TStringList;
    linha: string;

    function tiraLinhaBranca(Livro: TStringList): TStringlist;
    var
        i: integer;
    begin
        for i :=livro.count-1 downto 0 do
            if trim(livro[i]) = '' then
                livro.Delete(i);
        result := livro;
    end;
begin

    AssignFile(arquivo,endereco);
    {$I-}
    Reset(arquivo);
    {$I+}

    if ioresult <> 0 then
        begin
            mensagem ('Arquivo não encontrado.',0);
            halt;
        end;

    livro := TStringList.Create;
    while (not eof(arquivo)) do
         begin
           readln(arquivo,linha);
           livro.add (linha);
         end;

    closefile(arquivo);
    result := tiraLinhaBranca(livro);
end;

{--------------------------------------------------------}
{             Exibe o livro em txt na tela
{--------------------------------------------------------}

procedure exibeTxt;
var
    i, linhaInicial,linhaLida: integer;
    livro: TStringList;
    c1,c2: char;

begin
    linhaInicial := 1;
    linhaLida := 0;

    livro := abreTXT(caminhoCurTxt);
    repeat
        if (c1 = #0) and (c2 = ESQ) then
            begin
                if linhaInicial>0 then
                    begin
                        linhaLida := linhaInicial;
                        linhaInicial := linhaInicial -1;
                    end;
            end;
        if (c1 = #0) and (c2 = DIR) then
            begin
                if linhaInicial<livro.Count-1 then
                    begin
                        linhaLida := linhaInicial;
                        linhaInicial := linhaInicial +1;
                    end;
            end;

        clrscr;
        gotoxy(1,1);
        TextColor(Blue);
        sintWriteln(livro[linhaLida]);
        TextColor(white);

        for i:=linhaInicial to linhaInicial+23 do
            begin
                writeln(livro[i]);
            end;
        sintLeTecla(c1,c2);

    until c1 = ESC;
    readln;

end;

end.
