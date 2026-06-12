{-------------------------------------------------------------}
{
{    Traduvox - Módulo de interação
}
{    Autor: Jose' Antonio Borges
{
{    Em Janeiro/2010
{
{-------------------------------------------------------------}

unit trintera;

interface
uses
  dvinet,
  dvwin,
  dvcrt,
  dvform,
  dvarq,
  sysUtils,
  trmsg,
  trvars,
  trtraduz;

procedure processaInterativo;

implementation


function pegaLinguas (var linguaOrig, linguaDest: string): boolean;
var i,
    n: integer;
    nomeLingua1, nomelingua2: string;
label desistiu;
begin
    linguaOrig := 'AUTO';
    linguaDest := '';

    if uppercase(sintAmbiente('TRADUVOX', 'DETECTARIDIOMA', 'NAO'))[1] = 'S' then
        nomeLingua1 := linguas[1].nome
    else
        begin
            garanteEspacoTela (10);
            mensagem ('TRLINORG', 0);  {'Selecione a língua original com as setas: '}
            popupMenuCria(wherex, wherey, 15, 10, RED);
            for i := 1 to maxLinguas do
                with linguas[i] do
                    popupMenuAdiciona(som, nome);
            n := popupMenuSeleciona;

            if n = 0 then
                goto desistiu;

            linguaOrig := linguas[n].cod;
            writeln (opcoesItemSelecionado);
            nomeLingua1 := opcoesItemSelecionado;
        end;

    garanteEspacoTela (10);
    writeln;
    mensagem ('TRLINDST', 0);  {'Selecione a língua destino com as setas: '}
    popupMenuCria(wherex, wherey, 15, 10, RED);
    for i := 2 to maxLinguas do
        with linguas[i] do
            popupMenuAdiciona(som, nome);
    n := popupMenuSeleciona;

    if n = 0 then goto desistiu;

    linguaDest := linguas[n+1].cod;
    writeln (opcoesItemSelecionado);
    nomeLingua2 := opcoesItemSelecionado;

    writeln;
    mensagem ('TRSELEC', 0);   {'Tradução escolhida: '}
    textBackground (MAGENTA);
    sintWriteln (nomeLingua1 + pegaTextoMensagem('TRPARA') + nomeLingua2);
    textBackground (BLACK);

    pegaLinguas := true;
    exit;

desistiu:
    writeln;
    mensagem ('TRDESIST', 1);   {'Desistiu...'}
    pegaLinguas := false;
end;

function pegaOpcoesTraducao (var tipoOrigem, tipoDestino: char;
                             var nomeArqOrigem, nomeArqDestino: string): boolean;
var n: integer;
label desistiu;
begin
    writeln;
    garanteEspacoTela (3);
    mensagem ('TRTIPORI', 0);  {'Escolha com as setas o objeto a traduzir:'}
    popupMenuCria(wherex, wherey, 30, 3, RED);
    popupMenuAdiciona ('TREDICAO', pegaTextoMensagem('TREDICAO'));   {'L - Linha de edição'}
    popupMenuAdiciona ('TRTRARQ',  pegaTextoMensagem('TRTRARQ'));    {'A - Arquivo'}
    popupMenuAdiciona ('TRAREATR', pegaTextoMensagem('TRAREATR'));   {'T - Área de transferência'}
    n := popupMenuSeleciona;

    if n = 0 then goto desistiu;
    writeln (opcoesItemSelecionado);
    tipoOrigem := opcoesItemSelecionado[1];

    writeln;
    garanteEspacoTela (3);
    mensagem ('TRTIPDST', 0);  {'Escolha com as setas o destino:'}
    popupMenuCria(wherex, wherey, 30, 3, RED);
    popupMenuAdiciona ('TREDITAV', pegaTextoMensagem('TREDITAV'));   {'L - Linha editável'}
    popupMenuAdiciona ('TRTRARQ',  pegaTextoMensagem('TRTRARQ'));    {'A - Arquivo'}
    popupMenuAdiciona ('TRAREATR', pegaTextoMensagem('TRAREATR'));   {'T - Área de transferência'}

    n := popupMenuSeleciona;

    if n = 0 then goto desistiu;

    writeln (opcoesItemSelecionado);
    tipoDestino := opcoesItemSelecionado[1];

    writeln;
    garanteEspacoTela (11);
    if tipoOrigem = 'A' then
        begin
            mensagem ('TRINFARQ', 1);  {'Informe o nome do arquivo a traduzir:'}
            nomeArqOrigem := obtemNomeArq(10);
            if nomeArqOrigem = '' then goto desistiu;
            writeln (nomeArqOrigem);
        end;

    writeln;
    garanteEspacoTela (11);
    if tipoDestino = 'A' then
        begin
            mensagem ('TRINFGER', 1);  {'Informe o nome do arquivo a gerar:'}
            nomeArqDestino := obtemNomeArq(10);
            if nomeArqDestino = '' then goto desistiu;
            writeln (nomeArqDestino);
        end;

    pegaOpcoesTraducao := true;
    exit;

desistiu:
    writeln;
    mensagem ('TRDESIST', 1);   {'Desistiu...'}
    pegaOpcoesTraducao := false;
end;

procedure processaInterativo;
var tipoOrigem, tipoDestino: char;
    c1, c2: char;
label desistiu;
begin
    repeat
        if not pegaLinguas (linguaOrig, linguaDest) then
            goto desistiu;

        if not pegaOpcoesTraducao (tipoOrigem, tipoDestino,
                                  nomeArqOrig, nomeArqDest) then
            goto desistiu;

        if (tipoDestino = 'A') and (nomeArqDest <> '') and (FileExists(nomeArqDest)) then
            begin
                 mensagem ('TRARQEXI', 0);    {'Arquivo já existe, quer remover ou adicionar ao final? '}
                 sintLeTecla (c1, c2);
                 writeln;
                 if c1 = ESC then goto desistiu;
                 if upcase (c1) = 'R' then
                     DeleteFile (nomeArqDest);
            end;

        case tipoOrigem of
             'L':  traduzFrases (tipoDestino, nomeArqDest);
             'A':  traduzArquivo (nomeArqOrig, tipoDestino, nomeArqDest);
             'T':  traduzClipBoard (tipoDestino, nomeArqDest);
        end;

desistiu:
//        writeln;
        mensagem ('TRMAIS', 0);   {'Deseja fazer mais traduções? '}
        sintLeTecla(c1, c2);
        writeln;

        if upcase (c1) = 'S' then
            begin
                clrscr;
                textBackground (BLUE);
                writeln (pegaTextoMensagem ('TRINIC'), versao);    {'TRADUVOX - NCE/UFRJ - v.'}
                textBackground (BLACK);
                writeln; writeln;
            end;

    until upcase(c1) <> 'S';
end;

end.
