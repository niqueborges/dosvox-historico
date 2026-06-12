{--------------------------------------------------------}
{            Fichavox - selecao de fichas
{--------------------------------------------------------}

unit fvSelect;
interface
    uses dvcrt, dvwin, fvVars, fvMsg;

    procedure seleciona;

implementation

{--------------------------------------------------------}
{                 seleciona fichas
{--------------------------------------------------------}

procedure seleciona;

    procedure marcaTodos;
    var i: integer;
    begin
        for i := 1 to numFichas do
            fichario[i]^.selecionado := true;
    end;

    {--------------------------------------------------------}

    procedure desmarcaTodos;
    var i: integer;
    begin
        for i := 1 to numFichas do
            fichario[i]^.selecionado := false;
    end;

    {--------------------------------------------------------}

    procedure marcaUltimoLido;
    begin
        if posAtual <= 0 then exit;
        fichario[posAtual]^.selecionado := true;
    end;

    {--------------------------------------------------------}

    procedure desmarcaUltimoLido;
    begin
        if posAtual > 0 then
            fichario[posAtual]^.selecionado := false;
    end;

var opcao, quem, c2: char;
begin
    textBackGround (red);
    mensagem ('FVSELDES', 0);   {'Seleciona ou desseleciona ? '}
    textBackGround (black);
    sintLeTecla (opcao, c2);
    writeln;
    opcao := upcase (opcao);

    if not (opcao in ['S', 'D']) then
        begin
            mensagem ('FVDESIST', 1);   {'desistiu'}
            exit;
        end;

    textBackGround (magenta);
    mensagem ('FVTODULT', 0);    {'Todos ou último lido ? '}
    textBackGround (black);
    sintLeTecla (quem, c2);
    writeln;
    quem := upcase (quem);

    if not (quem in ['T', 'U']) then
        begin
            mensagem ('FVDESIST', 1);   {'desistiu'}
            exit;
        end;

    if (opcao = 'S') then
        begin
            if (quem = 'T') then marcaTodos
                            else marcaUltimoLido;
            mensagem ('FVSELEC', 1);    {'Selecionado'}
        end
    else
        begin
            if (quem = 'T') then desmarcaTodos
                            else desmarcaUltimoLido;
            mensagem ('FVNSELEC', 1);    {'Não selecionado'}
        end;
end;

end.
