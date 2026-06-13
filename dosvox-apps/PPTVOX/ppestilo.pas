unit ppEstilo;

interface

uses dvCrt, dvWin, dvArq, dvForm,
    windows, sysUtils,
    ppArq, ppMsg, ppVars;

procedure defineEstilo;
procedure criaEstilo;

implementation

{--------------------------------------------------------}

procedure defineEstilo;
var arq: text;
    s: string;
    erro: integer;
begin

    if nomeEstilo = '' then
    begin
        writeln;
        mensagem ('PPDEFEST', 0); {('Selecione com as setas o estilo desejado : ');}
        garanteEspacoTela (11);
        nomeEstilo:= obtemNomeArqMasc (10, '*.EST');
        writeln (nomeEstilo);
        if nomeEstilo = '' then
        begin
            capturouEstilo:= false; //Possibilita que capture posteriormente do arquivo .est
            mensagem ('PPDESIST', 1);
            exit;
        end;
    end;

    if not existeArq(nomeEstilo) then
    begin
        sintBip;
        nomeEstilo:= '';
        capturouEstilo:= false;
        writeln;
        mensagem ('PPPROARQ', 1); {('Estilo inexistente, terei de assumir valores pré-definidos');}
        exit;
    end;

    assign (arq, nomeEstilo);
    {$I-} reset(arq); {$I+}
    if ioResult <> 0 then
        exit;

    while not eof (arq) do
    begin
        readln (arq, s);

        if copy (s, 1, 7) = 'RESOLU=' then
        begin
            delete (s, 1, 7);
            resolucaoEstilo:= s;
        end;

        if copy (s, 1, 7) = 'FIGFUN=' then
        begin
            delete (s, 1, 7);
            figuraDeFundo:= s;
//            Caso erro : será assumido padrão em ppDesen.pas
        end;

        if copy (s, 1, 7) = 'CORLET=' then
        begin
            delete (s, 1, 7);
            corLetra:= s;
//            Caso erro : será assumido padrão em ppDesen.pas
        end;

        if copy (s, 1, 7) = 'FONTIT=' then
        begin
            delete (s, 1, 7);
            f_tit:= s;
            if f_tit = '' then f_tit:= 'Times New Roman';
        end;

        if copy (s, 1, 7) = 'FONLIN=' then
        begin
            delete (s, 1, 7);
            f_lin:= s;
            if f_lin = '' then f_lin:= 'Arial';
        end;

        if copy (s, 1, 7) = 'TAMTIT=' then
        begin
            delete (s, 1, 7);
            val (s, t_tit, erro);
            if erro <> 0 then t_tit:= 36;
        end;

        if copy (s, 1, 7) = 'TAMLIN=' then
        begin
            delete (s, 1, 7);
            val (s, t_lin, erro);
            if erro <> 0 then t_lin:= 24;
        end;

        if copy (s, 1, 7) = 'MARESQ=' then
        begin
            // deprecado
        end;

        if copy (s, 1, 7) = 'MARSUP=' then
        begin
            // deprecado
        end;

        if copy (s, 1, 7) = 'XTITUL=' then
        begin
            delete (s, 1, 7);
            val (s, xTitulo, erro);
            if erro <> 0 then xTitulo := 20;
        end;

        if copy (s, 1, 7) = 'YTITUL=' then
        begin
            delete (s, 1, 7);
            val (s, yTitulo, erro);
            if erro <> 0 then yTitulo := 30;
        end;

        if copy (s, 1, 7) = 'XDETAL=' then
        begin
            delete (s, 1, 7);
            val (s, xDetalhe, erro);
            if erro <> 0 then xDetalhe := 60;
        end;

        if copy (s, 1, 7) = 'YDETAL=' then
        begin
            delete (s, 1, 7);
            val (s, yDetalhe, erro);
            if erro <> 0 then yDetalhe:= 60;
        end;

    end;

    {$I-} close(arq); {$I+}
    if ioResult <> 0 then
        exit;

    capturouEstilo:= true;

    sintSom ('PPOK');

    if debugar then
        sintetiza ('CAPTUREI PARÂMETROS RELATIVOS AO ESTILO');

end;

{--------------------------------------------------------}

procedure criaEstilo;
var arq: text;
    opcao: char;
begin

    delay (100);
    writeln;
    mensagem ('PPDECRPA', 0); {('Deseja também criar um novo estilo a partir desses parâmetros ? ');}
    opcao:= sintReadkey;
    writeln (opcao);

    if (upcase(opcao) <> 'S') and (opcao <> ENTER) then
    begin
        mensagem ('PPDESIST', 1);
        exit;
    end;

    writeln;
    mensagem ('PPEDIEST', 1); {('OK, edite um nome para esse estilo : ');}
    opcao:= sintEditaCampo (novoNomeEstilo, 1, wherey, 200, 80, true);
    if opcao = ESC then
    begin
        mensagem ('PPDESIST', 1);
        exit;
    end;

    if novoNomeEstilo = '' then
        novoNomeEstilo:= 'Novo estilo';

    if pos ('.', novoNomeEstilo) <> 0 then
        delete (novoNomeEstilo, pos ('.', novoNomeEstilo), length (novoNomeEstilo));
    novoNomeEstilo:= novoNomeEstilo+ '.EST';

    if existeArq(novoNomeEstilo) then
    begin
        sintBip; sintBip;
        writeln;
        mensagem ('PPESTEXI', 1); {('Estilo existente, irei redefinir seus parâmetros');}
    end;

    if not existeArq(trim(figuraDeFundo)) then
    begin
        sintBip; sintBip;
        writeln;
        mensagem ('PPASSPAD', 1); {('Figura de fundo inexistente, assumirei o padrão');}
        writeln;
        figuraDeFundo := fundoPadrao;
    end;

    if resolucaoGrafica = '' then
        resolucaoGrafica:= '1024 por 768';

    assign (arq, novoNomeEstilo);
    {$I-} rewrite(arq); {$I+}
    if ioResult <> 0 then
        exit;

    writeln (arq, 'RESOLU=' + resolucaoGrafica);
    writeln (arq, 'FIGFUN=' + figuraDeFundo);
    writeln (arq, 'CORLET=' + corLetra);
    writeln (arq, 'FONTIT=' + f_tit);
    writeln (arq, 'FONLIN=' + f_lin);
    writeln (arq, 'TAMTIT=' + intToStr(t_tit));
    writeln (arq, 'TAMLIN=' + intToStr(t_lin));

    {$I-} close(arq); {$I+}
    if ioResult <> 0 then
        exit;

    nomeEstilo:= novoNomeEstilo;
    capturouEstilo:= true;

    sintSom ('PPOK');

end;

end.
